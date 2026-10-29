defmodule HologramBeamOpsKanbanSchemasTest do
  use ExUnit.Case, async: true

  alias HologramBeamOpsKanban.Boards.Board
  alias HologramBeamOpsKanban.Boards.Column
  alias HologramBeamOpsKanban.Tasks.Task

  describe "Board.changeset/2" do
    test "accepts a valid board name" do
      changeset = Board.changeset(%Board{}, %{name: "Engineering"})

      assert changeset.valid?
    end

    test "requires a name" do
      changeset = Board.changeset(%Board{}, %{})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "rejects a blank name" do
      changeset = Board.changeset(%Board{}, %{name: "   "})

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end
  end

  describe "Column.changeset/2" do
    test "accepts valid column attributes" do
      changeset =
        Column.changeset(%Column{}, %{
          name: "To Do",
          position: 0,
          board_id: 1
        })

      assert changeset.valid?
    end

    test "rejects a negative position" do
      changeset =
        Column.changeset(%Column{}, %{
          name: "To Do",
          position: -1,
          board_id: 1
        })

      refute changeset.valid?

      assert "must be greater than or equal to %{number}" in errors_on(changeset).position
    end
  end

  describe "Task.changeset/2" do
    test "accepts valid task attributes without a description" do
      changeset =
        Task.changeset(%Task{}, %{
          title: "Implement persistence",
          position: 0,
          column_id: 1
        })

      assert changeset.valid?
    end

    test "requires a title" do
      changeset =
        Task.changeset(%Task{}, %{
          position: 0,
          column_id: 1
        })

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "rejects a blank title" do
      changeset =
        Task.changeset(%Task{}, %{
          title: "   ",
          position: 0,
          column_id: 1
        })

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "rejects a negative position" do
      changeset =
        Task.changeset(%Task{}, %{
          title: "Implement persistence",
          position: -1,
          column_id: 1
        })

      refute changeset.valid?

      assert "must be greater than or equal to %{number}" in errors_on(changeset).position
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} -> message end)
  end
end
