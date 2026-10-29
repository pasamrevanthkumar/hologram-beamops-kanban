defmodule HologramBeamOpsKanban.Tasks.Task do
  @moduledoc """
  Represents a task within a Kanban column.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HologramBeamOpsKanban.Boards.Column

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :position, :integer
    field :completed_at, :utc_datetime_usec

    belongs_to :column, Column

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating or updating a task.
  """
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :position, :completed_at, :column_id])
    |> validate_required([:title, :position, :column_id])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> validate_change(:title, fn :title, title ->
      if String.trim(title) == "" do
        [title: "must not be blank"]
      else
        []
      end
    end)
    |> foreign_key_constraint(:column_id)
    |> unique_constraint([:column_id, :position],
      name: :tasks_column_id_position_index
    )
    |> check_constraint(:title, name: :tasks_title_not_blank)
    |> check_constraint(:position, name: :tasks_position_non_negative)
  end
end
