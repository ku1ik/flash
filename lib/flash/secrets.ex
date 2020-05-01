defmodule Flash.Secrets do
  @moduledoc """
  The Secrets context.
  """

  def add_secret(text, ttl \\ nil) do
    if valid?(text) do
      {:ok, do_add_secret(text, ttl)}
    else
      {:error, :invalid}
    end
  end

  defp valid?(text) do
    String.trim(text) != "" && String.length(text) < 100_000
  end

  defp do_add_secret(plain_text, ttl) do
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

  def burn_secret!(id) do
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
    Application.get_env(:flash, :encryption_key)
  end
end
