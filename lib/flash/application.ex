defmodule Flash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    redis_url = Application.get_env(:flash, :redis_url)

    children = [
      # Start the Telemetry supervisor
      FlashWeb.Telemetry,
      # Start Redis connection
      %{id: Redix, start: {Redix, :start_link, [redis_url, [name: Redix]]}},
      # Start the PubSub system
      {Phoenix.PubSub, name: Flash.PubSub},
      # Start rate limiter
      {PlugAttack.Storage.Ets, name: FlashWeb.PlugAttack.Storage, clean_period: 60_000},
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
end
