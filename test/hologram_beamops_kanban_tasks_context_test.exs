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
