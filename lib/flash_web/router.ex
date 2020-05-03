defmodule FlashWeb.Router do
  use FlashWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FlashWeb do
    pipe_through :browser

    get "/", SecretController, :new
    post "/", SecretController, :create
    get "/s/:id", SecretController, :preview
    post "/s/:id", SecretController, :reveal
  end

  # Other scopes may use custom stacks.
  # scope "/api", FlashWeb do
  #   pipe_through :api
  # end

  pipeline :admin do
    plug :browser
    plug :auth
  end

  scope "/admin" do
    pipe_through :admin

    live_dashboard "/dashboard", metrics: FlashWeb.Telemetry
  end

  defp auth(conn, _opts) do
    import Plug.BasicAuth
    import Plug.Crypto

    with {user, pass} <- parse_basic_auth(conn),
         true <- secure_compare(user, Application.fetch_env!(:flash, :admin_username)),
         true <- secure_compare(pass, Application.fetch_env!(:flash, :admin_password)) do
      conn
    else
      _ -> conn |> request_basic_auth() |> halt()
    end
  end
end
