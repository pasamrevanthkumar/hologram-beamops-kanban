defmodule HologramBeamOpsKanban.BoardsContextTest do
  use HologramBeamOpsKanban.DataCase, async: true

  alias HologramBeamOpsKanban.Boards
  alias HologramBeamOpsKanban.Boards.Board

  describe "list_boards/0" do
    test "returns boards ordered by ID" do
      assert {:ok, first_board} =
               Boards.create_board(%{name: "Engineering"})

      assert {:ok, second_board} =
               Boards.create_board(%{name: "Product"})

      assert Enum.map(Boards.list_boards(), & &1.id) == [
               first_board.id,
               second_board.id
             ]
    end

    test "returns an empty list when no boards exist" do
      assert Boards.list_boards() == []
    end
  end

  describe "get_board!/1" do
    test "returns the board with the given ID" do
      assert {:ok, board} =
               Boards.create_board(%{name: "Engineering"})

      assert Boards.get_board!(board.id).id == board.id
    end

    test "raises when the board does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Boards.get_board!(-1)
      end
    end
  end

  describe "create_board/1" do
    test "creates a board with valid attributes" do
      assert {:ok, %Board{} = board} =
               Boards.create_board(%{name: "Engineering"})

      assert board.id != nil
      assert board.name == "Engineering"
    end

    test "returns a changeset error for a blank name" do
      assert {:error, changeset} =
               Boards.create_board(%{name: "   "})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end
  end
end
