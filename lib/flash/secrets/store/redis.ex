defmodule Flash.Secrets.Store.Redis do
  @behaviour Flash.Secrets.Store

  @impl true
  def child_spec do
    redis_url = Application.get_env(:flash, :redis_url)

    %{id: __MODULE__, start: {Redix, :start_link, [redis_url, [name: __MODULE__]]}}
  end

  @impl true
  def put_secret(id, payload, ttl) do
    cmd!(["SET", redis_key_name(id), payload])
    cmd!(["EXPIRE", redis_key_name(id), ttl])

    :ok
  end

  @impl true
  def get_secret(id) do
    cmd!(["GET", redis_key_name(id)])
  end

  @impl true
  def delete_secret(id) do
    cmd!(["DEL", redis_key_name(id)])

    :ok
  end

  defp cmd!(args) do
    Redix.command!(__MODULE__, args)
  end

  defp redis_key_name(id), do: "secret:" <> id
end
