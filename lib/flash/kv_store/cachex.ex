defmodule Flash.KvStore.Cachex do
  @behaviour Flash.KvStore

  @impl true
  def child_spec do
    %{id: __MODULE__, start: {Cachex, :start_link, [__MODULE__, []]}}
  end

  @impl true
  def put(key, payload, ttl) do
    Cachex.put!(__MODULE__, key, payload, ttl: ttl * 1_000)

    :ok
  end

  @impl true
  def get(key) do
    Cachex.get!(__MODULE__, key)
  end

  @impl true
  def delete(key) do
    Cachex.del!(__MODULE__, key)

    :ok
  end
end
