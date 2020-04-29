defmodule FlashWeb.SecretController do
  use FlashWeb, :controller
  alias Flash.Secrets

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"secret" => %{"text" => text} = secret}) do
    ttl = String.to_integer(secret["ttl"] || "3600")

    case Secrets.add_secret(text, ttl) do
      {:ok, id} ->
        conn
        |> remember_secret_id(id)
        |> put_flash(:info, "Secret created successfully.")
        |> redirect(to: Routes.secret_path(conn, :preview, id))

      {:error, :invalid} ->
        render(conn, "new.html", error: true)
    end
  end

  def preview(conn, %{"id" => id}) do
    url = Routes.secret_url(conn, :preview, id)

    if Secrets.get_secret(id) do
      conn
      |> assign_active_secret_ids()
      |> render("preview.html", id: id, url: url)
    else
      render(conn, "not_found.html")
    end
  end

  def reveal(conn, %{"id" => id}) do
    if text = Secrets.get_secret(id) do
      Secrets.burn_secret!(id)
      render(conn, "show.html", secret: text)
    else
      render(conn, "not_found.html")
    end
  end

  defp remember_secret_id(conn, id) do
    secret_ids =
      case conn.req_cookies["secret_ids"] do
        nil ->
          id

        secret_ids ->
          secret_ids <> "|" <> id
      end

    put_resp_cookie(conn, "secret_ids", secret_ids)
  end

  defp assign_active_secret_ids(conn) do
    case conn.req_cookies["secret_ids"] do
      nil ->
        assign(conn, :active_secret_ids, [])

      ids ->
        ids =
          ids
          |> String.split("|")
          |> Enum.filter(&Secrets.get_secret/1)

        case ids do
          [] ->
            conn
            |> assign(:active_secret_ids, [])
            |> delete_resp_cookie("secret_ids")

          ids ->
            conn
            |> assign(:active_secret_ids, ids)
            |> put_resp_cookie("secret_ids", Enum.join(ids, "|"))
        end
    end
  end
end
