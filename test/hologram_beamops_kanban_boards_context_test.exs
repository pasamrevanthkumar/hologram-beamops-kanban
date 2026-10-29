defmodule HologramBeamOpsKanban.BoardsContextTest do
  use HologramBeamOpsKanban.DataCase, async: true

  alias HologramBeamOpsKanban.Boards
  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column

  describe "list_boards/0" do
    test "returns all boards ordered by ID" do
      {:ok, first_board} = Boards.create_board(%{name: "First board"})
      {:ok, second_board} = Boards.create_board(%{name: "Second board"})

      assert Boards.list_boards() == [first_board, second_board]
    end

    test "returns an empty list when no boards exist" do
      assert Boards.list_boards() == []
    end
  end

  describe "get_board!/1" do
    test "returns the board with the given ID" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert Boards.get_board!(board.id) == board
    end

    test "raises when the board does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Boards.get_board!(-1)
      end
    end
  end

  describe "create_board/1" do
    test "creates a board with valid attributes" do
      assert {:ok, %Board{name: "Engineering"}} =
               Boards.create_board(%{name: "Engineering"})
    end

    test "returns a changeset error for a blank name" do
      assert {:error, changeset} = Boards.create_board(%{name: "   "})

      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "list_columns/1" do
    test "returns a board's columns ordered by position" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      {:ok, second_column} =
        Boards.create_column(board.id, %{name: "In Progress", position: 1})

      {:ok, first_column} =
        Boards.create_column(board.id, %{name: "To Do", position: 0})

      assert Boards.list_columns(board.id) == [first_column, second_column]
    end

    test "returns an empty list when the board has no columns" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert Boards.list_columns(board.id) == []
    end
  end

  describe "create_column/2" do
    test "creates a column belonging to the specified board" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert {:ok,
              %Column{
                name: "To Do",
                position: 0,
                board_id: board_id
              }} = Boards.create_column(board.id, %{name: "To Do", position: 0})

      assert board_id == board.id
    end

    test "returns a changeset error for a blank column name" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert {:error, changeset} =
               Boards.create_column(board.id, %{name: "   ", position: 0})

      assert "can't be blank" in errors_on(changeset).name
    end

    test "returns a changeset error for a negative position" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert {:error, changeset} =
               Boards.create_column(board.id, %{name: "To Do", position: -1})

      assert "must be greater than or equal to 0" in errors_on(changeset).position
    end

    test "returns a changeset error when required attributes are missing" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      assert {:error, changeset} = Boards.create_column(board.id, %{})

      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).position
    end

    test "returns a changeset error for a nonexistent board" do
      assert {:error, changeset} =
               Boards.create_column(-1, %{name: "To Do", position: 0})

      assert %{board_id: [_message]} = errors_on(changeset)
    end
  end

  describe "column position integrity" do
    test "rejects duplicate column positions within the same board" do
      {:ok, board} = Boards.create_board(%{name: "Engineering"})

      {:ok, _column} =
        Boards.create_column(board.id, %{name: "To Do", position: 0})

      assert {:error, changeset} =
               Boards.create_column(board.id, %{name: "In Progress", position: 0})

      assert %{board_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "allows the same column position on different boards" do
      {:ok, first_board} = Boards.create_board(%{name: "Engineering"})
      {:ok, second_board} = Boards.create_board(%{name: "Operations"})

      assert {:ok, _first_column} =
               Boards.create_column(first_board.id, %{name: "To Do", position: 0})

      assert {:ok, _second_column} =
               Boards.create_column(second_board.id, %{name: "To Do", position: 0})
    end
  end
end
