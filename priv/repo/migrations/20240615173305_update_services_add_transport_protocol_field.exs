defmodule PtahServer.Repo.Migrations.UpdateServicesAddTransportProtocolField do
  use Ecto.Migration

  def change do
    execute """
      UPDATE services
      SET spec = jsonb_set(
        spec,
        '{endpoint_spec,caddy}',
        (
          SELECT jsonb_agg(
                  jsonb_set(
                    item,
                    '{transport_protocol}',
                    '"http"'::jsonb
                  )
                )
          FROM jsonb_array_elements(spec->'endpoint_spec'->'caddy') AS item
        )
      )
      WHERE jsonb_array_length(spec->'endpoint_spec'->'caddy') > 0;
    """
  end
end
