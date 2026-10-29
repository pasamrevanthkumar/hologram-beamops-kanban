defmodule HologramBeamOpsKanban.Repo.Migrations.CreateKanbanTables do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create constraint(:boards, :boards_name_not_blank, check: "length(trim(name)) > 0")

    create table(:columns) do
      add :board_id, references(:boards, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :position, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:columns, [:board_id])

    create unique_index(:columns, [:board_id, :position], name: :columns_board_id_position_index)

    create constraint(:columns, :columns_name_not_blank, check: "length(trim(name)) > 0")

    create constraint(:columns, :columns_position_non_negative, check: "position >= 0")

    create table(:tasks) do
      add :column_id, references(:columns, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :description, :text
      add :position, :integer, null: false
      add :completed_at, :utc_datetime_usec

      timestamps(type: :utc_datetime_usec)
    end

    create index(:tasks, [:column_id])

    create unique_index(:tasks, [:column_id, :position], name: :tasks_column_id_position_index)

    create constraint(:tasks, :tasks_title_not_blank, check: "length(trim(title)) > 0")

    create constraint(:tasks, :tasks_position_non_negative, check: "position >= 0")
  end
end
