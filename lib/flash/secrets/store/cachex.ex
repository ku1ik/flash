defmodule Flash.Secrets.Store.Cachex do
  @behaviour Flash.Secrets.Store

  @impl true
  def child_spec do
    %{id: __MODULE__, start: {Cachex, :start_link, [__MODULE__, []]}}
  end

  @impl true
  def put_secret(id, payload, ttl) do
    Cachex.put!(__MODULE__, id, payload, ttl: ttl * 1_000)

    :ok
  end

  @impl true
  def get_secret(id) do
    Cachex.get!(__MODULE__, id)
  end

  @impl true
  def delete_secret(id) do
    Cachex.del!(__MODULE__, id)

    :ok
  end
end
