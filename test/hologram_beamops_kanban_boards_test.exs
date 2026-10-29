defmodule HologramBeamOpsKanban.BoardsTest do
  use HologramBeamOpsKanban.DataCase, async: true

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Tasks.Task

  describe "boards" do
    test "creates and retrieves a board" do
      assert {:ok, %Board{} = board} =
               %Board{}
               |> Board.changeset(%{name: "Engineering"})
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

  describe "database constraints" do
    test "rejects a column referencing a nonexistent board" do
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%Column{
          name: "To Do",
          position: 0,
          board_id: -1
        })
      end
    end

    test "rejects a task referencing a nonexistent column" do
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%Task{
          title: "Invalid task",
          position: 0,
          column_id: -1
        })
      end
    end

    test "rejects duplicate column positions within a board" do
      assert {:ok, board} =
               %Board{}
               |> Board.changeset(%{name: "Engineering"})
               |> Repo.insert()

      assert {:ok, _column} =
               %Column{}
               |> Column.changeset(%{
                 name: "To Do",
                 position: 0,
                 board_id: board.id
               })
               |> Repo.insert()

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%Column{
          name: "In Progress",
          position: 0,
          board_id: board.id
        })
      end
    end

    test "rejects duplicate task positions within a column" do
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

      assert {:ok, _task} =
               %Task{}
               |> Task.changeset(%{
                 title: "First task",
                 position: 0,
                 column_id: column.id
               })
               |> Repo.insert()

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%Task{
          title: "Second task",
          position: 0,
          column_id: column.id
        })
      end
    end
  end
end
