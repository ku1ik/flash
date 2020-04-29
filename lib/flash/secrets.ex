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
    String.trim(text) != "" && String.length(text) < 100_000
  end

  defp do_create_secret(plain_text, ttl) do
    id = Nanoid.generate()
    payload = encrypt(plain_text)
    Redix.command!(Redix, ["SET", redis_key_name(id), payload])

    if ttl do
      Redix.command!(Redix, ["EXPIRE", redis_key_name(id), ttl])
    end

    id
  end

  def get_secret(id) do
    if payload = Redix.command!(Redix, ["GET", redis_key_name(id)]) do
      decrypt(payload)
    end
  end

  def delete_secret!(id) do
    Redix.command!(Redix, ["DEL", redis_key_name(id)])

    :ok
  end

  defp redis_key_name(id), do: "secret:" <> id

  @aad "AES256GCM"

  defp encrypt(plain_text) do
    iv = :crypto.strong_rand_bytes(16)

    {cipher_text, tag} =
      :crypto.block_encrypt(:aes_gcm, encryption_key(), iv, {@aad, plain_text, 16})

    Base.encode64(iv <> tag <> cipher_text)
  end

  defp decrypt(payload) do
    payload = Base.decode64!(payload)
    <<iv::binary-16, tag::binary-16, cipher_text::binary>> = payload

    :crypto.block_decrypt(:aes_gcm, encryption_key(), iv, {@aad, cipher_text, tag})
  end

  defp encryption_key do
    key =
      :flash
      |> Application.get_env(FlashWeb.Endpoint)
      |> Keyword.get(:secret_key_base)
      |> Base.decode64!()

    <<key::binary-size(32), _rest::binary>> = key

    key
  end
end
