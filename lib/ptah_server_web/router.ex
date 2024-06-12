defmodule PtahServerWeb.Router do
  require Logger
  use PtahServerWeb, :router

  import PtahServerWeb.UserAuth

  import PtahServerWeb.Plug.CurrentTeam, only: [fetch_default_team: 2]
  # import PtahServerWeb.Plug.CurrentTeam

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PtahServerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :analytics
    plug :fetch_default_team
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_api_team
    plug OpenApiSpex.Plug.PutApiSpec, module: PtahServerWeb.ApiSpec
  end

  pipeline :api_docs do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: PtahServerWeb.ApiSpec
  end

  scope "/api/v1" do
    pipe_through :browser

    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/api/v1/openapi.json"
  end

  scope "/", PtahServerWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api/v1" do
    pipe_through :api_docs

    get "/openapi.json", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api/v1", PtahServerWeb do
    pipe_through :api

    post "/services/:service_id/deploy", ServiceDeployController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ptah_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PtahServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PtahServerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {PtahServerWeb.UserAuth, :redirect_if_user_is_authenticated},
        {PtahServerWeb.Plug.CurrentTeam, :assign_nil_team}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PtahServerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :user_portal,
      on_mount: [
        {PtahServerWeb.UserAuth, :ensure_authenticated},
        {PtahServerWeb.Plug.CurrentTeam, :ensure_team_selection}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end

    live_session :require_authenticated_user,
      on_mount: [
        {PtahServerWeb.UserAuth, :ensure_authenticated},
        {PtahServerWeb.Plug.CurrentTeam, :ensure_team_access}
      ] do
      scope "/teams/:team_id" do
        # pipe_through [:require_team_access]

        live "/swarms", SwarmLive.Index, :index
        live "/swarms/new", SwarmLive.Index, :new
        live "/swarms/:id/edit", SwarmLive.Index, :edit

        live "/swarms/:id", SwarmLive.Show, :show
        live "/swarms/:id/show/edit", SwarmLive.Show, :edit

        live "/servers", ServerLive.Index, :index
        live "/servers/new", ServerLive.Index, :new
        live "/servers/:id/edit", ServerLive.Index, :edit

        live "/servers/:id", ServerLive.Show, :show
        live "/servers/:id/show/edit", ServerLive.Show, :edit

        live "/stacks", StackLive.Index, :index
        live "/stacks/new", StackLive.Index, :new
        live "/stacks/:id/edit", StackLive.Index, :edit

        live "/stacks/:id", StackLive.Show, :show
        live "/stacks/:id/show/edit", StackLive.Show, :edit

        live "/services", ServiceLive.Index, :index
        live "/services/new", ServiceLive.Index, :new
        live "/services/:id/edit", ServiceLive.Index, :edit

        live "/services/:id", ServiceLive.Show, :show
        live "/services/:id/show/edit", ServiceLive.Show, :edit

        live "/docker_configs", DockerConfigLive.Index, :index
        live "/docker_configs/new", DockerConfigLive.Index, :new
        live "/docker_configs/:id/edit", DockerConfigLive.Index, :edit

        live "/docker_configs/:id", DockerConfigLive.Show, :show
        live "/docker_configs/:id/show/edit", DockerConfigLive.Show, :edit

        live "/docker_registries", DockerRegistryLive.Index, :index
        live "/docker_registries/new", DockerRegistryLive.Index, :new
        live "/docker_registries/:id/edit", DockerRegistryLive.Index, :edit

        live "/docker_registries/:id", DockerRegistryLive.Show, :show
        live "/docker_registries/:id/show/edit", DockerRegistryLive.Show, :edit
      end
    end
  end

  scope "/", PtahServerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [
        {PtahServerWeb.UserAuth, :mount_current_user},
        {PtahServerWeb.Plug.CurrentTeam, :assign_nil_team}
      ] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  defp analytics(conn, _otps) do
    assign(
      conn,
      :analytics,
      Keyword.fetch!(Application.get_env(:ptah_server, :analytics), :enabled)
    )
  end
end
