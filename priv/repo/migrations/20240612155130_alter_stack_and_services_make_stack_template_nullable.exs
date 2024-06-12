defmodule PtahServer.Repo.Migrations.AlterStackAndServicesMakeStackTemplateNullable do
  use Ecto.Migration

  def change do
    alter table(:services) do
      modify :service_name, :string, null: true
    end

    alter table(:stacks) do
      modify :stack_name, :string, null: true
      modify :stack_version, :string, null: true
    end
  end
end
