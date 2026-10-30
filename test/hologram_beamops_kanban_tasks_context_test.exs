defmodule HologramBeamOpsKanban.TasksContextTest do
  use HologramBeamOpsKanban.DataCase, async: true

  alias HologramBeamOpsKanban.Boards
  alias HologramBeamOpsKanban.Repo
  alias HologramBeamOpsKanban.Tasks
  alias HologramBeamOpsKanban.Tasks.Task

  defp create_column(name \\ "To Do", position \\ 0) do
    {:ok, board} = Boards.create_board(%{name: "Engineering"})

    {:ok, column} =
      Boards.create_column(board.id, %{name: name, position: position})

    column
  end

  defp create_task(column) do
    {:ok, task} =
      Tasks.create_task(column.id, %{
        title: "Build feature",
        position: 0
      })

    task
  end

  describe "list_tasks/1" do
    test "returns tasks ordered by position" do
      column = create_column()

      {:ok, second_task} =
        Tasks.create_task(column.id, %{title: "Write tests", position: 1})

      {:ok, first_task} =
        Tasks.create_task(column.id, %{title: "Build feature", position: 0})

      assert Tasks.list_tasks(column.id) == [first_task, second_task]
    end

    test "returns an empty list when a column has no tasks" do
      column = create_column()

      assert Tasks.list_tasks(column.id) == []
    end
  end

  describe "create_task/2" do
    test "creates a task with a title and position" do
      column = create_column()

      assert {:ok,
              %Task{
                title: "Build feature",
                position: 0,
                column_id: column_id
              }} =
               Tasks.create_task(column.id, %{
                 title: "Build feature",
                 position: 0
               })

      assert column_id == column.id
    end

    test "creates a task with an optional description" do
      column = create_column()

      assert {:ok, %Task{description: "Add automated tests"}} =
               Tasks.create_task(column.id, %{
                 title: "Build feature",
                 description: "Add automated tests",
                 position: 0
               })
    end

    test "returns a changeset error when the title is blank" do
      column = create_column()

      assert {:error, changeset} =
               Tasks.create_task(column.id, %{title: "   ", position: 0})

      assert "can't be blank" in errors_on(changeset).title
    end

    test "returns a changeset error for a negative position" do
      column = create_column()

      assert {:error, changeset} =
               Tasks.create_task(column.id, %{title: "Build feature", position: -1})

      assert "must be greater than or equal to 0" in errors_on(changeset).position
    end

    test "returns a changeset error when required attributes are missing" do
      column = create_column()

      assert {:error, changeset} = Tasks.create_task(column.id, %{})

      assert "can't be blank" in errors_on(changeset).title
      assert "can't be blank" in errors_on(changeset).position
    end

    test "returns a changeset error for a nonexistent column" do
      assert {:error, changeset} =
               Tasks.create_task(-1, %{title: "Build feature", position: 0})

      assert %{column_id: [_message]} = errors_on(changeset)
    end
  end

  describe "get_task!/1" do
    test "returns the task with the given ID" do
      column = create_column()
      task = create_task(column)

      assert Tasks.get_task!(task.id) == task
    end

    test "raises when the task does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Tasks.get_task!(-1)
      end
    end
  end

  describe "update_task/2" do
    test "updates a task's title and description" do
      column = create_column()
      task = create_task(column)

      assert {:ok, updated_task} =
               Tasks.update_task(task, %{
                 title: "Build the feature",
                 description: "Add tests"
               })

      assert updated_task.title == "Build the feature"
      assert updated_task.description == "Add tests"
    end

    test "returns a changeset error for an invalid update" do
      column = create_column()
      task = create_task(column)

      assert {:error, changeset} = Tasks.update_task(task, %{title: "   "})

      assert "can't be blank" in errors_on(changeset).title
    end
  end

  describe "complete_task/1" do
    test "marks a task complete with a UTC timestamp" do
      task = create_task(create_column())

      assert {:ok, completed_task} = Tasks.complete_task(task)
      assert %DateTime{} = completed_task.completed_at
      assert completed_task.completed_at.time_zone == "Etc/UTC"
    end

    test "persists the completion timestamp" do
      task = create_task(create_column())

      assert {:ok, completed_task} = Tasks.complete_task(task)

      persisted_task = Tasks.get_task!(task.id)

      assert persisted_task.completed_at == completed_task.completed_at
    end
  end

  describe "reopen_task/1" do
    test "clears a task's completion timestamp" do
      task = create_task(create_column())

      {:ok, completed_task} = Tasks.complete_task(task)

      assert {:ok, reopened_task} = Tasks.reopen_task(completed_task)
      assert is_nil(reopened_task.completed_at)
    end

    test "persists the reopened state" do
      task = create_task(create_column())

      {:ok, completed_task} = Tasks.complete_task(task)
      {:ok, _reopened_task} = Tasks.reopen_task(completed_task)

      assert is_nil(Tasks.get_task!(task.id).completed_at)
    end
  end

  describe "move_task/2" do
    test "moves a task toward the beginning and shifts other tasks" do
      column = create_column()

      {:ok, first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      {:ok, second} =
        Tasks.create_task(column.id, %{title: "Second", position: 1})

      {:ok, third} =
        Tasks.create_task(column.id, %{title: "Third", position: 2})

      assert {:ok, moved_task} = Tasks.move_task(third, 0)

      assert moved_task.position == 0

      assert Enum.map(Tasks.list_tasks(column.id), &{&1.title, &1.position}) ==
               [{"Third", 0}, {"First", 1}, {"Second", 2}]

      assert Tasks.get_task!(first.id).position == 1
      assert Tasks.get_task!(second.id).position == 2
    end

    test "moves a task toward the end and shifts other tasks" do
      column = create_column()

      {:ok, first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      {:ok, second} =
        Tasks.create_task(column.id, %{title: "Second", position: 1})

      {:ok, third} =
        Tasks.create_task(column.id, %{title: "Third", position: 2})

      assert {:ok, moved_task} = Tasks.move_task(first, 2)

      assert moved_task.position == 2

      assert Enum.map(Tasks.list_tasks(column.id), &{&1.title, &1.position}) ==
               [{"Second", 0}, {"Third", 1}, {"First", 2}]

      assert Tasks.get_task!(second.id).position == 0
      assert Tasks.get_task!(third.id).position == 1
    end

    test "returns an error for a negative position without changing the order" do
      column = create_column()

      {:ok, _first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      {:ok, second} =
        Tasks.create_task(column.id, %{title: "Second", position: 1})

      assert {:error, :invalid_position} = Tasks.move_task(second, -1)

      assert Enum.map(Tasks.list_tasks(column.id), &{&1.title, &1.position}) ==
               [{"First", 0}, {"Second", 1}]
    end

    test "returns an error when the position is outside the column's task range" do
      column = create_column()

      {:ok, first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      assert {:error, :invalid_position} = Tasks.move_task(first, 1)

      assert Tasks.list_tasks(column.id) == [first]
    end

    test "keeps the order unchanged when moving a task to its current position" do
      column = create_column()

      {:ok, _first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      {:ok, second} =
        Tasks.create_task(column.id, %{title: "Second", position: 1})

      assert {:ok, unchanged_task} = Tasks.move_task(second, 1)
      assert unchanged_task.position == 1

      assert Enum.map(Tasks.list_tasks(column.id), &{&1.title, &1.position}) ==
               [{"First", 0}, {"Second", 1}]
    end

    test "normalizes positions when moving tasks in a column with gaps" do
      column = create_column()

      {:ok, first} =
        Tasks.create_task(column.id, %{title: "First", position: 0})

      {:ok, second} =
        Tasks.create_task(column.id, %{title: "Second", position: 2})

      {:ok, third} =
        Tasks.create_task(column.id, %{title: "Third", position: 4})

      assert {:ok, _moved_task} = Tasks.move_task(third, 0)

      assert Enum.map(Tasks.list_tasks(column.id), &{&1.title, &1.position}) ==
               [{"Third", 0}, {"First", 1}, {"Second", 2}]

      assert Tasks.get_task!(first.id).position == 1
      assert Tasks.get_task!(second.id).position == 2
    end
  end

  describe "move_task_to_column/3" do
    test "moves a task to a destination column and normalizes both columns" do
      source_column = create_column("To Do")
      destination_column = create_column("In Progress")

      {:ok, first} =
        Tasks.create_task(source_column.id, %{title: "First", position: 0})

      {:ok, moved} =
        Tasks.create_task(source_column.id, %{title: "Moved", position: 1})

      {:ok, third} =
        Tasks.create_task(source_column.id, %{title: "Third", position: 2})

      {:ok, destination_first} =
        Tasks.create_task(destination_column.id, %{title: "Destination first", position: 0})

      {:ok, destination_second} =
        Tasks.create_task(destination_column.id, %{title: "Destination second", position: 1})

      assert {:ok, updated_task} =
               Tasks.move_task_to_column(moved, destination_column.id, 1)

      assert updated_task.column_id == destination_column.id
      assert updated_task.position == 1

      assert Enum.map(Tasks.list_tasks(source_column.id), &{&1.title, &1.position}) ==
               [{"First", 0}, {"Third", 1}]

      assert Enum.map(Tasks.list_tasks(destination_column.id), &{&1.title, &1.position}) ==
               [
                 {"Destination first", 0},
                 {"Moved", 1},
                 {"Destination second", 2}
               ]

      assert Tasks.get_task!(first.id).position == 0
      assert Tasks.get_task!(third.id).position == 1
      assert Tasks.get_task!(destination_first.id).position == 0
      assert Tasks.get_task!(destination_second.id).position == 2
    end

    test "moves a task into an empty destination column" do
      source_column = create_column("To Do")
      destination_column = create_column("Done")

      task = create_task(source_column)

      assert {:ok, moved_task} =
               Tasks.move_task_to_column(task, destination_column.id, 0)

      assert moved_task.column_id == destination_column.id
      assert moved_task.position == 0

      assert Tasks.list_tasks(source_column.id) == []
      assert Tasks.list_tasks(destination_column.id) == [moved_task]
    end

    test "allows inserting a task at the end of the destination column" do
      source_column = create_column("To Do")
      destination_column = create_column("In Progress")

      task = create_task(source_column)

      {:ok, existing} =
        Tasks.create_task(destination_column.id, %{title: "Existing", position: 0})

      assert {:ok, moved_task} =
               Tasks.move_task_to_column(task, destination_column.id, 1)

      assert moved_task.position == 1

      assert Enum.map(Tasks.list_tasks(destination_column.id), & &1.title) ==
               ["Existing", "Build feature"]

      assert Tasks.get_task!(existing.id).position == 0
    end

    test "returns an error for a negative destination position without changing either column" do
      source_column = create_column("To Do")
      destination_column = create_column("In Progress")

      task = create_task(source_column)
      destination_task = create_task(destination_column)

      assert {:error, :invalid_position} =
               Tasks.move_task_to_column(task, destination_column.id, -1)

      assert Tasks.list_tasks(source_column.id) == [task]
      assert Tasks.list_tasks(destination_column.id) == [destination_task]
    end

    test "returns an error when the destination position is out of range" do
      source_column = create_column("To Do")
      destination_column = create_column("In Progress")

      task = create_task(source_column)
      destination_task = create_task(destination_column)

      assert {:error, :invalid_position} =
               Tasks.move_task_to_column(task, destination_column.id, 2)

      assert Tasks.list_tasks(source_column.id) == [task]
      assert Tasks.list_tasks(destination_column.id) == [destination_task]
    end

    test "returns an error when the destination column does not exist" do
      source_column = create_column()
      task = create_task(source_column)

      assert {:error, :column_not_found} =
               Tasks.move_task_to_column(task, -1, 0)

      assert Tasks.list_tasks(source_column.id) == [task]
    end

    test "returns an error for a non-integer destination position" do
      source_column = create_column()
      destination_column = create_column("Done")
      task = create_task(source_column)

      assert {:error, :invalid_position} =
               Tasks.move_task_to_column(task, destination_column.id, "0")

      assert Tasks.list_tasks(source_column.id) == [task]
      assert Tasks.list_tasks(destination_column.id) == []
    end

    test "uses the existing same-column move behavior" do
      column = create_column()

      {:ok, first} = Tasks.create_task(column.id, %{title: "First", position: 0})
      {:ok, _second} = Tasks.create_task(column.id, %{title: "Second", position: 1})

      assert {:ok, moved_task} =
               Tasks.move_task_to_column(first, column.id, 1)

      assert moved_task.column_id == column.id
      assert moved_task.position == 1

      assert Enum.map(Tasks.list_tasks(column.id), & &1.title) ==
               ["Second", "First"]
    end
  end

  describe "delete_task/1" do
    test "deletes the task" do
      task = create_task(create_column())

      assert {:ok, deleted_task} = Tasks.delete_task(task)
      assert deleted_task.id == task.id

      assert_raise Ecto.NoResultsError, fn ->
        Tasks.get_task!(task.id)
      end
    end
  end

  describe "get_task_column!/1" do
    test "returns the column containing the task" do
      column = create_column()
      task = create_task(column)

      assert Tasks.get_task_column!(task.id) == column
    end

    test "raises when the task does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Tasks.get_task_column!(-1)
      end
    end
  end

  describe "task position integrity" do
    test "rejects duplicate task positions within the same column" do
      column = create_column()

      {:ok, _first_task} =
        Tasks.create_task(column.id, %{title: "First task", position: 0})

      assert {:error, changeset} =
               Tasks.create_task(column.id, %{title: "Second task", position: 0})

      assert %{column_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "allows the same task position in different columns" do
      first_column = create_column("To Do", 0)
      second_column = create_column("In Progress", 0)

      assert {:ok, _first_task} =
               Tasks.create_task(first_column.id, %{
                 title: "First task",
                 position: 0
               })

      assert {:ok, _second_task} =
               Tasks.create_task(second_column.id, %{
                 title: "Second task",
                 position: 0
               })
    end
  end

  describe "database integrity" do
    test "the task remains persisted after retrieving it from the database" do
      column = create_column()
      task = create_task(column)

      retrieved_task = Repo.get!(Task, task.id)

      assert retrieved_task.title == "Build feature"
      assert retrieved_task.column_id == column.id
    end
  end
end
