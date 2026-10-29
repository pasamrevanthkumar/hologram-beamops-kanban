defmodule HologramBeamOpsKanban.Boards.Column do
  @moduledoc """
  Represents an ordered column on a Kanban board.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Tasks.Task

  schema "columns" do
    field :name, :string
    field :position, :integer

    belongs_to :board, Board
    has_many :tasks, Task, on_replace: :delete

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating or updating a column.
  """
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:name, :position, :board_id])
    |> validate_required([:name, :position, :board_id])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> validate_change(:name, fn :name, name ->
      if String.trim(name) == "" do
        [name: "must not be blank"]
      else
        []
      end
    end)
    |> foreign_key_constraint(:board_id)
    |> unique_constraint([:board_id, :position],
      name: :columns_board_id_position_index
    )
    |> check_constraint(:name, name: :columns_name_not_blank)
    |> check_constraint(:position, name: :columns_position_non_negative)
  end
end
