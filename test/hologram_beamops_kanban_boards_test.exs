defmodule HologramBeamOpsKanban.BoardsTest do
  use HologramBeamOpsKanban.DataCase, async: true

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Tasks.Task

  describe "boards" do
    test "creates and retrieves a board" do
      attrs = %{name: "Engineering"}

      assert {:ok, %Board{} = board} =
               %Board{}
               |> Board.changeset(attrs)
               |> Repo.insert()

      assert board.id != nil
      assert board.name == "Engineering"

      retrieved_board = Repo.get!(Board, board.id)

      assert retrieved_board.id == board.id
      assert retrieved_board.name == "Engineering"
    end

    test "creates a board with a column and a task" do
      assert {:ok, board} =
               %Board{}
               |> Board.changeset(%{name: "Engineering"})
               |> Repo.insert()

      assert {:ok, column} =
               %Column{}
               |> Column.changeset(%{
                 name: "To Do",
                 position: 0,
                 board_id: board.id
               })
               |> Repo.insert()

      assert {:ok, task} =
               %Task{}
               |> Task.changeset(%{
                 title: "Implement persistence",
                 description: "Save Kanban data in PostgreSQL",
                 position: 0,
                 column_id: column.id
               })
               |> Repo.insert()

      retrieved_column = Repo.get!(Column, column.id)
      retrieved_task = Repo.get!(Task, task.id)

      assert retrieved_column.board_id == board.id
      assert retrieved_task.column_id == column.id
      assert retrieved_task.title == "Implement persistence"
    end
  end
end
