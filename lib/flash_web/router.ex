defmodule FlashWeb.Router do
  use FlashWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug Plug.SSL, rewrite_on: [:x_forwarded_proto], hsts: true, host: nil
    plug :accepts, ["html", "text"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery, with: :clear_session
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
    delete "/s/:id", SecretController, :delete
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
         pass_sha1 = Base.encode16(:crypto.hash(:sha, pass), case: :lower),
         true <- secure_compare(user, Application.fetch_env!(:flash, :admin_username)),
         true <- secure_compare(pass_sha1, Application.fetch_env!(:flash, :admin_password_sha1)) do
      conn
    else
      _ -> conn |> request_basic_auth() |> halt()
    end
  end
end
