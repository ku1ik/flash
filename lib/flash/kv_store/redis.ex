defmodule Flash.KvStore.Redis do
  @behaviour Flash.KvStore

  @impl true
  def child_spec do
    redis_url = Application.get_env(:flash, :redis_url)

    %{id: __MODULE__, start: {Redix, :start_link, [redis_url, [name: __MODULE__]]}}
  end

  @impl true
  def put(key, value, ttl) do
    cmd!(["SET", full_key_name(key), value])
    cmd!(["EXPIRE", full_key_name(key), ttl])

    :ok
  end

  @impl true
  def get(key) do
    cmd!(["GET", full_key_name(key)])
  end

  @impl true
  def delete(key) do
    cmd!(["DEL", full_key_name(key)])

    :ok
  end

  defp cmd!(args) do
    Redix.command!(__MODULE__, args)
  end

  defp full_key_name(key), do: "secret:" <> key
end
