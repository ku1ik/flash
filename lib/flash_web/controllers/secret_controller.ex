defmodule FlashWeb.SecretController do
  use FlashWeb, :controller
  alias Flash.Secrets

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"secret" => %{"text" => text} = secret}) do
    ttl = String.to_integer(secret["ttl"] || "3600")

    case Secrets.create_secret(text, ttl) do
      {:ok, id} ->
        conn
        |> put_flash(:info, "Secret created successfully.")
        |> redirect(to: Routes.secret_path(conn, :preview, id))

      {:error, reason} ->
        render(conn, "new.html", error: reason)
    end
  end

  def preview(conn, %{"id" => id}) do
    render(conn, "preview.html", id: id)
  end

  def reveal(conn, %{"id" => id}) do
    case Secrets.fetch_secret(id) do
      {:ok, text} ->
        Secrets.delete_secret!(id)
        render(conn, "show.html", secret: text)

      {:error, :not_found} ->
        render(conn, "not_found.html")
    end
  end
end
