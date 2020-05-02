defmodule FlashWeb.SecretController do
  use FlashWeb, :controller
  alias Flash.Secrets

  @year_in_seconds 3600 * 24 * 365
  @week_in_seconds 3600 * 24 * 7
  @ids_cookie_name "secret_ids"
  @ids_cookie_opts [max_age: @week_in_seconds, extra: "SameSite=Lax", sign: true]

  plug FlashWeb.PlugAttack
  plug :fetch_cookies, signed: [@ids_cookie_name]

  def new(conn, _params) do
    render(conn, "new.html", default_ttl: get_default_ttl(conn))
  end

  def create(conn, %{"secret" => %{"text" => text} = secret}) do
    ttl = String.to_integer(secret["ttl"] || "3600")

    case Secrets.add_secret(text, ttl) do
      {:ok, id} ->
        conn
        |> save_secret_id(id)
        |> save_default_ttl(ttl)
        |> put_flash(:info, "Your secret was securely saved.")
        |> redirect(to: Routes.secret_path(conn, :preview, id))

      {:error, :invalid} ->
        render(conn, "new.html", default_ttl: get_default_ttl(conn), error: true)
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

  defp save_secret_id(conn, id) do
    secret_ids =
      case conn.cookies["secret_ids"] do
        nil ->
          id

        secret_ids ->
          secret_ids <> "|" <> id
      end

    save_secret_ids_cookie(conn, secret_ids)
  end

  def save_default_ttl(conn, ttl) do
    put_resp_cookie(conn, "default_ttl", to_string(ttl), max_age: @year_in_seconds)
  end

  def get_default_ttl(conn) do
    String.to_integer(conn.cookies["default_ttl"] || "3600")
  end

  defp assign_active_secret_ids(conn) do
    case conn.cookies["secret_ids"] do
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
            |> clear_secret_ids_cookie()

          ids ->
            conn
            |> assign(:active_secret_ids, ids)
            |> save_secret_ids_cookie(Enum.join(ids, "|"))
        end
    end
  end

  defp save_secret_ids_cookie(conn, value) do
    put_resp_cookie(conn, @ids_cookie_name, value, @ids_cookie_opts)
  end

  defp clear_secret_ids_cookie(conn) do
    delete_resp_cookie(conn, @ids_cookie_name)
  end
end
