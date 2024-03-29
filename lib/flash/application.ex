defmodule Flash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    store_child_spec = Flash.Secrets.store_child_spec()

    Logger.info("Using #{store_child_spec.id} for secrets storage")

    children = [
      # Start the Telemetry supervisor
      FlashWeb.Telemetry,
      # Start secrets store
      store_child_spec,
      # Start the PubSub system
      {Phoenix.PubSub, name: Flash.PubSub},
      # Start rate limiter
      {PlugAttack.Storage.Ets, name: FlashWeb.PlugAttack.Storage, clean_period: 60_000},
      # Start the Endpoint (http/https)
      FlashWeb.Endpoint
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
