defmodule HologramBeamOpsKanban.Boards do
  @moduledoc """
  Provides operations for managing Kanban boards and their columns.
  """

  import Ecto.Query, warn: false

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Repo

  @doc """
  Returns all boards, ordered by ID.
  """
  def list_boards do
    Repo.all(from board in Board, order_by: [asc: board.id])
  end

  @doc """
  Gets a board by ID.

  Raises `Ecto.NoResultsError` if the board does not exist.
  """
  def get_board!(id) do
    Repo.get!(Board, id)
  end

  @doc """
  Creates a board.

  Returns `{:ok, board}` on success or `{:error, changeset}` on failure.
  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists a board's columns in position order.
  """
  def list_columns(board_id) do
    Repo.all(
      from column in Column,
        where: column.board_id == ^board_id,
        order_by: [asc: column.position, asc: column.id]
    )
  end

  @doc """
  Creates a column for a board.

  Returns `{:ok, column}` on success or `{:error, changeset}` on failure.
  """
  def create_column(board_id, attrs) do
    attrs = Map.put(attrs, :board_id, board_id)

    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end
end
