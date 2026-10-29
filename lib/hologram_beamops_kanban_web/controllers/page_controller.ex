defmodule HologramBeamOpsKanbanWeb.PageController do
  use HologramBeamOpsKanbanWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
