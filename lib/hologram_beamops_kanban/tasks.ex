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
  """
  def create_task(column_id, attrs \\ %{}) do
    attrs = Map.put(attrs, :column_id, column_id)

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a task by ID.

  Raises Ecto.NoResultsError if the task does not exist.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Updates a task.
  """
  def update_task(task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
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

  defp normalize_task_positions!(tasks) do
    # First move every task above the current position range. This prevents
    # collisions with the unique (column_id, position) database constraint.
    max_position =
      tasks
      |> Enum.map(& &1.position)
      |> Enum.max(fn -> -1 end)

    temporary_offset = max_position + length(tasks) + 1

    Enum.each(tasks, fn current_task ->
      case update_task(current_task, %{
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
  def complete_task(task) do
    update_task(task, %{completed_at: DateTime.utc_now()})
  end

  @doc """
  Reopens a completed task.
  """
  def reopen_task(task) do
    update_task(task, %{completed_at: nil})
  end

  @doc """
  Deletes a task.
  """
  def delete_task(task), do: Repo.delete(task)

  @doc """
  Returns the column associated with a task ID.

  Raises Ecto.NoResultsError if the task does not exist.
  """
  def get_task_column!(task_id) do
    task = Repo.get!(Task, task_id)
    Repo.get!(Column, task.column_id)
  end
end
