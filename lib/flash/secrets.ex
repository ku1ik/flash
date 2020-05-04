defmodule Flash.Secrets do
  @moduledoc """
  The Secrets context.
  """

  def store_child_spec, do: store().child_spec()

  def add_secret(text, ttl \\ nil) do
    if valid?(text) do
      {:ok, do_add_secret(text, ttl)}
    else
      {:error, {:invalid, :secret}}
    end
  end

  defp valid?(text) do
    String.trim(text) != "" && String.length(text) < 100_000
  end

  defp do_add_secret(plain_text, ttl) do
    id = Nanoid.generate()
    payload = encrypt(plain_text)
    store().put_secret(id, payload, ttl)

    id
  end

  def get_secret(id) do
    if payload = store().get_secret(id) do
      decrypt(payload)
    end
  end

  def burn_secret!(id) do
    store().delete_secret(id)
  end

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

  defp store, do: Application.fetch_env!(:flash, :secrets_store)
end
