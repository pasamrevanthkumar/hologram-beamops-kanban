defmodule HologramBeamOpsKanban.Pages.HomePage do
  use Hologram.Page

  route "/"
  layout HologramBeamOpsKanban.Layouts.MainLayout

  def init(_params, component, _server) do
    put_state(component, :count, 0)
  end

  def template do
    ~HOLO"""
    <main>
      <h1>Engineering Elixir Applications</h1>
      <h2>Book Lifecycle — BeamOps Kanban</h2>

      <p>
        This application is running on Hologram.
      </p>

      <section>
        <h3>Integration Check</h3>
        <p>Counter: {@count}</p>
        <button $click="increment">Increment</button>
        <button $click="reset">Reset</button>
      </section>
    </main>
    """
  end

  def action(:increment, _params, component) do
    put_state(component, :count, component.state.count + 1)
  end

  def action(:reset, _params, component) do
    put_state(component, :count, 0)
  end
end
