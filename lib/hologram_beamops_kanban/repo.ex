defmodule HologramBeamOpsKanban.Repo do
  use Ecto.Repo,
    otp_app: :hologram_beamops_kanban,
    adapter: Ecto.Adapters.Postgres
end
