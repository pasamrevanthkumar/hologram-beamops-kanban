defmodule HologramBeamOpsKanban.Boards.Board do
  @moduledoc """
  Represents a Kanban board.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias HologramBeamOpsKanban.Boards.Column

  schema "boards" do
    field :name, :string
    has_many :columns, Column
    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Builds a changeset for creating or updating a board.
  """
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> validate_change(:name, fn :name, name ->
      if String.trim(name) == "" do
        [name: "must not be blank"]
      else
        []
      end
    end)
    |> check_constraint(:name, name: :boards_name_not_blank)
  end
end
