defmodule Flash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FlashWeb.Telemetry,
      # Start Redis connection
      {Redix, redis_opts()},
      # Start the PubSub system
      {Phoenix.PubSub, name: Flash.PubSub},
      # Start the Endpoint (http/https)
      FlashWeb.Endpoint
      # Start a worker by calling: Flash.Worker.start_link(arg)
      # {Flash.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FlashWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp redis_opts do
    redis_cfg = URI.parse(Application.get_env(:flash, :redis_url))
    redis_host = redis_cfg.host
    redis_port = redis_cfg.port
    redis_db = String.slice(to_string(redis_cfg.path), 1, 2)

    [host: redis_host, port: redis_port, database: redis_db, name: Redix]
  end
end
