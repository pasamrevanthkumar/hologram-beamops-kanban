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

  Returns `{:ok, task}` on success or `{:error, changeset}` on failure.
  """
  def create_task(column_id, attrs \\ %{}) do
    attrs = Map.put(attrs, :column_id, column_id)

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a task by ID.

  Raises `Ecto.NoResultsError` if the task does not exist.
  """
  def get_task!(id) do
    Repo.get!(Task, id)
  end

  @doc """
  Updates a task.

  Returns `{:ok, task}` on success or `{:error, changeset}` on failure.
  """
  def update_task(task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.
  """
  def delete_task(task) do
    Repo.delete(task)
  end

  @doc """
  Returns the column associated with a task ID.

  Raises `Ecto.NoResultsError` if the task does not exist.
  """
  def get_task_column!(task_id) do
    task = Repo.get!(Task, task_id)
    Repo.get!(Column, task.column_id)
  end
end
