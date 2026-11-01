defmodule HologramBeamOpsKanban.Pages.HomePage do
  use Hologram.Page

  alias HologramBeamOpsKanban.Boards
  alias HologramBeamOpsKanban.Tasks

  route "/"
  layout HologramBeamOpsKanban.Layouts.MainLayout

  def init(_params, component, _server) do
    boards = load_boards()

    put_state(component,
      boards: boards,
      board_count: length(boards),
      task_count: count_tasks(boards),
      board_feedback: nil,
      board_error: nil,
      task_feedback: nil,
      task_error: nil
    )
  end

  def template do
    ~HOLO"""
    <main class="app-shell">
      <header class="topbar">
        <a class="brand" href="/">
          <span class="brand-mark">B</span>
          <span class="brand-name">BEAMOPS</span>
        </a>

        <div class="environment-status">
          <span class="status-indicator"></span>
          LOCAL DEVELOPMENT
        </div>
      </header>

      <section class="hero">
        <div class="hero-copy">
          <p class="eyebrow">ENGINEERING ELIXIR APPLICATIONS</p>
          <h1>
            Engineering workflow,
            <span>orchestrated.</span>
          </h1>
          <p class="hero-description">
            A development operations workspace built with Elixir and Hologram.
            Plan, organize, and track your engineering work in one place.
          </p>
        </div>

        <div class="hero-decoration" aria-hidden="true">
          <div class="orbit orbit-one"></div>
          <div class="orbit orbit-two"></div>
          <div class="orbit-core">
            <span>BEAM</span>
          </div>
        </div>
      </section>

      <section class="overview-grid" aria-label="Workspace overview">
        <article class="metric-card">
          <div class="metric-icon metric-icon-purple">▦</div>
          <div>
            <p class="metric-label">TOTAL BOARDS</p>
            <p class="metric-value">{@board_count}</p>
          </div>
        </article>

        <article class="metric-card">
          <div class="metric-icon metric-icon-cyan">⌘</div>
          <div>
            <p class="metric-label">TOTAL WORK ITEMS</p>
            <p class="metric-value">{@task_count}</p>
          </div>
        </article>

        <article class="metric-card metric-card-highlight">
          <div class="metric-icon metric-icon-green">✓</div>
          <div>
            <p class="metric-label">APPLICATION STATUS</p>
            <p class="metric-status">Running locally</p>
          </div>
        </article>
      </section>

      <section class="creation-panel">
        <div class="section-heading">
          <div>
            <p class="eyebrow">GET STARTED</p>
            <h2>Create a workspace</h2>
            <p class="section-description">
              Give your engineering workflow a home.
            </p>
          </div>
          <div class="creation-symbol" aria-hidden="true">+</div>
        </div>

        <form class="board-form" $submit={command: :create_board}>
          <div class="form-field">
            <label for="board_name">Board name</label>
            <input
              class="board-input"
              type="text"
              id="board_name"
              name="name"
              placeholder="e.g. Platform Engineering"
              required
            />
          </div>
          <button class="primary-button" type="submit">
            <span>+</span>
            Create board
          </button>
        </form>

        {%if @board_feedback != nil}
          <p class="feedback-message">{@board_feedback}</p>
        {/if}

        {%if @board_error != nil}
          <p class="error-message" role="alert">{@board_error}</p>
        {/if}
        
        {%if @task_feedback != nil}
     <p class="feedback-message">{@task_feedback}</p>
        {/if}

        {%if @task_error != nil}
          <p class="error-message" role="alert">{@task_error}</p>
        {/if}
      </section>

      <section class="workspaces-section">
        <div class="section-heading workspace-heading">
          <div>
            <p class="eyebrow">YOUR WORKSPACE</p>
            <h2>Your boards</h2>
            <p class="section-description">
              All your engineering workflows, organized.
            </p>
          </div>

          <span class="count-badge">
            {@board_count} boards
          </span>
        </div>

        {%if @boards == []}
          <div class="empty-state">
            <div class="empty-state-icon">
              <span>▦</span>
            </div>
            <h3>No boards yet</h3>
            <p>
              Your workspace is ready. Create your first board above
              to start organizing engineering work.
            </p>
          </div>
        {%else}
          <div class="boards-grid">
            {%for board_data <- @boards}
              <article class="board-card">
                <div class="board-card-header">
                  <div class="board-card-icon">▦</div>
                  <div>
                    <h3>{board_data.board.name}</h3>
                    <p class="board-card-meta">
                      {length(board_data.columns)} columns
                    </p>
                  </div>
                </div>

                <div class="kanban-columns">
                  {%for column_data <- board_data.columns}
                    <section class="kanban-column">
                      <div class="column-heading">
                        <h4>{column_data.column.name}</h4>
                        <span class="task-count">
                          {length(column_data.tasks)}
                        </span>
                      </div>
                      <form class="task-form" $submit={command: :create_task}>
                        <input
    		  type="hidden"
    		  name="column_id"
    			  value={column_data.column.id}
    	/>
    	<input
    		  type="text"
    	  name="title"
    		  placeholder="Task title"
    	  required
           />
           <textarea
    		  name="description"
    		  placeholder="Description (optional)"
           ></textarea>
           <button type="submit">Add task</button>
        </form>
                      {%if column_data.tasks == []}
                        <p class="column-empty">
                          No tasks in this column.
                        </p>
                      {%else}
                        <div class="task-list">
                          {%for task <- column_data.tasks}
                            <article class="task-card">
                              <h5>{task.title}</h5>
                              <p>{task.description}</p>
                            </article>
                          {/for}
                        </div>
                      {/if}
                    </section>
                  {/for}
                </div>
              </article>
            {/for}
          </div>
        {/if}
      </section>

      <footer class="app-footer">
        <span>BEAMOPS KANBAN</span>
        <span>Built with Elixir &amp; Hologram</span>
      </footer>
    </main>
    """
  end

  def action(:board_creation_result, params, component) do
    case params.result do
      %{status: :ok, boards: boards} ->
        put_state(component,
          boards: boards,
          board_count: length(boards),
          task_count: count_tasks(boards),
          board_feedback: "Board created successfully.",
          board_error: nil
        )

      %{status: :error, message: message} ->
        put_state(component,
          board_feedback: nil,
          board_error: message
        )
    end
  end

  def action(:task_creation_result, params, component) do
    case params.result do
      %{status: :ok, boards: boards} ->
        put_state(component,
          boards: boards,
          board_count: length(boards),
          task_count: count_tasks(boards),
          task_feedback: "Task created successfully.",
          task_error: nil
        )

      %{status: :error, message: message} ->
        put_state(component,
          task_feedback: nil,
          task_error: message
        )
    end
  end

  def command(:create_task, params, server) do
    event = params.event

    column_id =
      case Integer.parse(Map.get(event, "column_id", "")) do
        {id, ""} when id > 0 -> id
        _ -> nil
      end

    title = Map.get(event, "title", "") |> String.trim()
    description = Map.get(event, "description", "") |> String.trim()

    if is_nil(column_id) or title == "" do
      put_action(server, :task_creation_result,
        result: %{
          status: :error,
          message: "Please provide a valid column and task title."
        }
      )
    else
      next_position =
        Tasks.list_tasks(column_id)
        |> length()

      case Tasks.create_task(column_id, %{
             title: title,
             description: description,
             position: next_position
           }) do
        {:ok, _task} ->
          put_action(server, :task_creation_result,
            result: %{
              status: :ok,
              boards: load_boards()
            }
          )

        {:error, changeset} ->
          message =
            if match?(%Ecto.Changeset{}, changeset) do
              errors =
                Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} ->
                  message
                end)

              errors
              |> Map.get(:title, ["Could not create task."])
              |> Enum.join(", ")
            else
              "Could not create task. Please try again."
            end

          put_action(server, :task_creation_result,
            result: %{
              status: :error,
              message: message
            }
          )
      end
    end
  end

  def command(:create_board, params, server) do
    name = Map.get(params.event, "name")

    case Boards.create_board_with_default_columns(%{name: name}) do
      {:ok, _board} ->
        put_action(server, :board_creation_result,
          result: %{
            status: :ok,
            boards: load_boards()
          }
        )

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {message, _opts} ->
            message
          end)

        message =
          errors
          |> Map.get(:name, ["Could not create board."])
          |> Enum.join(", ")

        put_action(server, :board_creation_result,
          result: %{
            status: :error,
            message: message
          }
        )
    end
  end

  defp count_tasks(boards) do
    Enum.reduce(boards, 0, fn board_data, total ->
      board_task_count =
        Enum.reduce(board_data.columns, 0, fn column_data, column_total ->
          column_total + length(column_data.tasks)
        end)

      total + board_task_count
    end)
  end

  defp load_boards do
    Enum.map(Boards.list_boards(), fn board ->
      columns =
        Enum.map(Boards.list_columns(board.id), fn column ->
          %{
            column: %{id: column.id, name: column.name},
            tasks:
              Enum.map(Tasks.list_tasks(column.id), fn task ->
                %{
                  title: task.title,
                  description: task.description
                }
              end)
          }
        end)

      %{
        board: %{name: board.name},
        columns: columns
      }
    end)
  end
end
