defmodule Flash.KvStore.S3 do
  @behaviour Flash.KvStore

  alias ExAws.S3

  @impl true
  def child_spec, do: %{id: __MODULE__, start: {__MODULE__, :start_link, []}}

  def start_link, do: :ignore

  @impl true
  def put(key, value, ttl) do
    expires_at =
      DateTime.utc_now()
      |> DateTime.add(ttl, :second)
      |> DateTime.to_iso8601()

    attrs = %{value: value, expires_at: expires_at}
    req = S3.put_object(cfg(:bucket), path(key), Jason.encode!(attrs))

    with {:ok, _} <- ExAws.request(req) do
      :ok
    end
  end

  @impl true
  def get(key) do
    req = S3.get_object(cfg(:bucket), path(key))

    case ExAws.request(req) do
      {:ok, %{body: body}} ->
        %{"value" => value, "expires_at" => expires_at} = Jason.decode!(body)
        {:ok, expires_at, _} = DateTime.from_iso8601(expires_at)

        if DateTime.diff(expires_at, DateTime.utc_now()) > 0 do
          value
        else
          :ok = delete(key)

          nil
        end

      {:error, {:http_error, 404, _}} ->
        nil
    end
  end

  @impl true
  def delete(key) do
    req = S3.delete_object(cfg(:bucket), path(key))

    with {:ok, _} <- ExAws.request(req) do
      :ok
    end
  end

  defp path(key), do: "#{cfg(:prefix)}secrets/#{key}"

  defp cfg(key) do
    Keyword.get(Application.fetch_env!(:flash, __MODULE__), key)
  end
end
