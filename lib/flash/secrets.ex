defmodule Flash.Secrets do
  @moduledoc """
  The Secrets context.
  """

  def create_secret(text, ttl \\ nil) do
    if valid?(text) do
      {:ok, do_create_secret(text, ttl)}
    else
      {:error, :invalid}
    end
  end

  defp valid?(text) do
    String.trim(text) != ""
  end

  defp do_create_secret(text, ttl) do
    id = Nanoid.generate()
    Redix.command!(Redix, ["SET", key(id), text])

    if ttl do
      Redix.command!(Redix, ["EXPIRE", key(id), ttl])
    end

    id
  end

  def fetch_secret(id) do
    case Redix.command!(Redix, ["GET", key(id)]) do
      nil ->
        {:error, :not_found}

      text ->
        {:ok, text}
    end
  end

  def delete_secret!(id) do
    Redix.command!(Redix, ["DEL", key(id)])

    :ok
  end

  defp key(id), do: "secret:" <> id
end
