defmodule HologramBeamOpsKanban.Boards do
  @moduledoc """
  Provides operations for managing Kanban boards and their columns.
  """

  import Ecto.Query, warn: false

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Repo

  @default_columns [
    %{name: "To Do", position: 0},
    %{name: "In Progress", position: 1},
    %{name: "Done", position: 2}
  ]

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
  Creates a board with the default Kanban columns.

  The board and its columns are created in a single transaction.

  Returns `{:ok, board}` on success or `{:error, reason}` on failure.
  """
  def create_board_with_default_columns(attrs \\ %{}) do
    Repo.transaction(fn ->
      board =
        case create_board(attrs) do
          {:ok, board} -> board
          {:error, changeset} -> Repo.rollback(changeset)
        end

      Enum.each(@default_columns, fn column_attrs ->
        case create_column(board.id, column_attrs) do
          {:ok, _column} -> :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)

      board
    end)
    |> case do
      {:ok, board} -> {:ok, board}
      {:error, reason} -> {:error, reason}
    end
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
