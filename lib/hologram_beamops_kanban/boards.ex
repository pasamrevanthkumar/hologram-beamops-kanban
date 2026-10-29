defmodule HologramBeamOpsKanban.Boards do
  @moduledoc """
  Provides operations for managing Kanban boards.
  """

  import Ecto.Query, warn: false

  alias HologramBeamOpsKanban.Boards.Board
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
end
