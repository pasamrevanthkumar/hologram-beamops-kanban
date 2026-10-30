defmodule HologramBeamOpsKanban.Tasks do
  @moduledoc """
  Provides operations for managing Kanban tasks.
  """

  import Ecto.Query, warn: false

  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Repo
  alias HologramBeamOpsKanban.Tasks.Task

  @doc """
  Lists a column's tasks in position order.
  """
  def list_tasks(column_id) do
    Repo.all(
      from task in Task,
        where: task.column_id == ^column_id,
        order_by: [asc: task.position, asc: task.id]
    )
  end

  @doc """
  Creates a task within the specified column.

  Locks the parent column before insertion so task creation is serialized
  with other operations that modify the column's task ordering.
  """
  def create_task(column_id, attrs \\ %{}) do
    attrs = Map.put(attrs, :column_id, column_id)

    Repo.transaction(fn ->
      Repo.one(
        from column in Column,
          where: column.id == ^column_id,
          lock: "FOR UPDATE"
      )

      case %Task{}
           |> Task.changeset(attrs)
           |> Repo.insert() do
        {:ok, task} ->
          {:ok, task}

        {:error, changeset} ->
          Repo.rollback({:changeset_error, changeset})
      end
    end)
    |> case do
      {:ok, {:ok, task}} ->
        {:ok, task}

      {:error, {:changeset_error, changeset}} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gets a task by ID.

  Raises Ecto.NoResultsError if the task does not exist.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Updates a task's editable metadata.

  Position, column membership, and completion status must be changed
  through their dedicated operations.

  Reloads and locks the task inside a transaction so updates operate
  on the current database record rather than a potentially stale struct.
  """
  def update_task(%Task{id: task_id}, attrs) when is_map(attrs) do
    allowed_attrs = [:title, :description, "title", "description"]

    if Enum.all?(Map.keys(attrs), &(&1 in allowed_attrs)) do
      Repo.transaction(fn ->
        current_task =
          Repo.one(
            from task in Task,
              where: task.id == ^task_id,
              lock: "FOR UPDATE"
          )

        if is_nil(current_task) do
          Repo.rollback(:task_not_found)
        end

        case Task.changeset(current_task, attrs)
             |> Repo.update() do
          {:ok, updated_task} ->
            updated_task

          {:error, changeset} ->
            Repo.rollback({:changeset_error, changeset})
        end
      end)
      |> case do
        {:ok, updated_task} ->
          {:ok, updated_task}

        {:error, {:changeset_error, changeset}} ->
          {:error, changeset}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :unsupported_task_attributes}
    end
  end

  defp update_task_record(task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  defp update_task_completion(task_id, completed_at) do
    Repo.transaction(fn ->
      current_task =
        Repo.one(
          from task in Task,
            where: task.id == ^task_id,
            lock: "FOR UPDATE"
        )

      if is_nil(current_task) do
        Repo.rollback(:task_not_found)
      end

      case update_task_record(current_task, %{completed_at: completed_at}) do
        {:ok, updated_task} ->
          updated_task

        {:error, changeset} ->
          Repo.rollback({:changeset_error, changeset})
      end
    end)
    |> case do
      {:ok, updated_task} ->
        {:ok, updated_task}

      {:error, {:changeset_error, changeset}} ->
        {:error, changeset}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Moves a task to a zero-based position within its current column.

  Reorders all tasks in a transaction and normalizes their positions.
  """
  def move_task(%Task{} = task, new_position) when is_integer(new_position) do
    Repo.transaction(fn ->
      column =
        Repo.one(
          from column in Column,
            where: column.id == ^task.column_id,
            lock: "FOR UPDATE"
        )

      if is_nil(column), do: Repo.rollback(:column_not_found)

      tasks =
        Repo.all(
          from current in Task,
            where: current.column_id == ^task.column_id,
            order_by: [asc: current.position, asc: current.id],
            lock: "FOR UPDATE"
        )

      case Enum.find_index(tasks, &(&1.id == task.id)) do
        nil ->
          Repo.rollback(:task_not_found)

        old_index ->
          task_count = length(tasks)

          if new_position < 0 or new_position >= task_count do
            Repo.rollback(:invalid_position)
          else
            ordered_tasks =
              tasks
              |> List.delete_at(old_index)
              |> List.insert_at(new_position, Enum.at(tasks, old_index))

            if Enum.all?(ordered_tasks, fn current_task ->
                 current_task.position ==
                   Enum.find_index(ordered_tasks, &(&1.id == current_task.id))
               end) do
              Repo.get!(Task, task.id)
            else
              normalize_task_positions!(ordered_tasks)
              Repo.get!(Task, task.id)
            end
          end
      end
    end)
    |> case do
      {:ok, moved_task} -> {:ok, moved_task}
      {:error, reason} -> {:error, reason}
    end
  end

  def move_task(%Task{}, _new_position), do: {:error, :invalid_position}

  @doc """
  Moves a task to another column at a zero-based position.

  Reorders both columns in a transaction and normalizes their positions.
  """
  def move_task_to_column(
        %Task{} = task,
        destination_column_id,
        new_position
      )
      when is_integer(destination_column_id) and is_integer(new_position) do
    if task.column_id == destination_column_id do
      move_task(task, new_position)
    else
      Repo.transaction(fn ->
        column_ids =
          [task.column_id, destination_column_id]
          |> Enum.sort()

        locked_columns =
          Repo.all(
            from column in Column,
              where: column.id in ^column_ids,
              order_by: [asc: column.id],
              lock: "FOR UPDATE"
          )

        if length(locked_columns) != 2 do
          Repo.rollback(:column_not_found)
        end

        current_task =
          Repo.one(
            from current in Task,
              where: current.id == ^task.id,
              lock: "FOR UPDATE"
          )

        cond do
          is_nil(current_task) ->
            Repo.rollback(:task_not_found)

          current_task.column_id != task.column_id ->
            Repo.rollback(:task_not_in_source_column)

          true ->
            source_tasks =
              Repo.all(
                from current in Task,
                  where: current.column_id == ^task.column_id,
                  order_by: [asc: current.position, asc: current.id],
                  lock: "FOR UPDATE"
              )

            destination_tasks =
              Repo.all(
                from current in Task,
                  where: current.column_id == ^destination_column_id,
                  order_by: [asc: current.position, asc: current.id],
                  lock: "FOR UPDATE"
              )

            if new_position < 0 or new_position > length(destination_tasks) do
              Repo.rollback(:invalid_position)
            end

            source_tasks =
              Enum.reject(source_tasks, &(&1.id == current_task.id))

            destination_tasks =
              List.insert_at(destination_tasks, new_position, current_task)

            temporary_position =
              (source_tasks ++ destination_tasks)
              |> Enum.map(& &1.position)
              |> Enum.max(fn -> -1 end)
              |> Kernel.+(length(source_tasks) + length(destination_tasks) + 1)

            updated_task =
              case update_task_record(current_task, %{
                     column_id: destination_column_id,
                     position: temporary_position
                   }) do
                {:ok, updated_task} ->
                  updated_task

                {:error, changeset} ->
                  Repo.rollback(changeset)
              end

            destination_tasks =
              Enum.map(destination_tasks, fn destination_task ->
                if destination_task.id == updated_task.id do
                  updated_task
                else
                  destination_task
                end
              end)

            normalize_task_positions!(source_tasks)
            normalize_task_positions!(destination_tasks)

            Repo.get!(Task, current_task.id)
        end
      end)
      |> case do
        {:ok, moved_task} -> {:ok, moved_task}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def move_task_to_column(%Task{}, _destination_column_id, _new_position) do
    {:error, :invalid_position}
  end

  defp normalize_task_positions!(tasks) do
    # First move every task above the current position range. This prevents
    # collisions with the unique (column_id, position) database constraint.
    max_position =
      tasks
      |> Enum.map(& &1.position)
      |> Enum.max(fn -> -1 end)

    temporary_offset = max_position + length(tasks) + 1

    Enum.each(tasks, fn current_task ->
      case update_task_record(current_task, %{
             position: temporary_offset + current_task.id
           }) do
        {:ok, _updated_task} -> :ok
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)

    # All positions are now temporary and unique, so assigning contiguous
    # zero-based positions cannot collide with the previous positions.
    tasks
    |> Enum.with_index()
    |> Enum.each(fn {current_task, position} ->
      case Repo.update(
             Task.changeset(
               Repo.get!(Task, current_task.id),
               %{position: position}
             )
           ) do
        {:ok, _updated_task} -> :ok
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Marks a task as complete using the current UTC time.
  """
  def complete_task(%Task{id: task_id}) do
    update_task_completion(task_id, DateTime.utc_now())
  end

  @doc """
  Reopens a completed task.
  """
  def reopen_task(%Task{id: task_id}) do
    update_task_completion(task_id, nil)
  end

  @doc """
  Deletes a task and normalizes the remaining positions in its column.

  The deletion and position normalization happen in one transaction.
  """
  def delete_task(%Task{} = task) do
    Repo.transaction(fn ->
      column =
        Repo.one(
          from column in Column,
            where: column.id == ^task.column_id,
            lock: "FOR UPDATE"
        )

      if is_nil(column), do: Repo.rollback(:column_not_found)

      current_task =
        Repo.one(
          from current in Task,
            where: current.id == ^task.id,
            lock: "FOR UPDATE"
        )

      cond do
        is_nil(current_task) ->
          Repo.rollback(:task_not_found)

        current_task.column_id != task.column_id ->
          Repo.rollback(:task_not_in_column)

        true ->
          tasks =
            Repo.all(
              from current in Task,
                where: current.column_id == ^task.column_id,
                order_by: [asc: current.position, asc: current.id],
                lock: "FOR UPDATE"
            )

          case Repo.delete(current_task) do
            {:ok, deleted_task} ->
              remaining_tasks =
                Enum.reject(tasks, &(&1.id == deleted_task.id))

              normalize_task_positions!(remaining_tasks)

              deleted_task

            {:error, changeset} ->
              Repo.rollback(changeset)
          end
      end
    end)
    |> case do
      {:ok, deleted_task} -> {:ok, deleted_task}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns the column associated with a task ID.

  Raises Ecto.NoResultsError if the task does not exist.
  """
  def get_task_column!(task_id) do
    task = Repo.get!(Task, task_id)
    Repo.get!(Column, task.column_id)
  end
end
