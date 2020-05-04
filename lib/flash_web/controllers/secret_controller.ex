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
    render(conn, "new.html",
      ttl_options: Application.fetch_env!(:flash, :ttl_options),
      default_ttl: get_default_ttl(conn)
    )
  end

  def create(conn, params) do
    secret = to_string(params["secret"])

    with {:ok, ttl} <- parse_ttl(params["ttl"]),
         {:ok, id} <- Secrets.add_secret(secret, ttl) do
        on_created(conn, id, ttl)
    else
      {:error, {:invalid, field}} ->
        on_invalid(conn, field)
    end
  end

  defp parse_ttl(nil), do: {:ok, 3600}

  defp parse_ttl(ttl) when is_integer(ttl), do: {:ok, ttl}

  defp parse_ttl(ttl) do
    case Integer.parse(to_string(ttl)) do
      {ttl, ""} ->
        {:ok, ttl}

      {ttl, "s"} ->
        {:ok, ttl}

      {ttl, "m"} ->
        {:ok, ttl * 60}

      {ttl, "h"} ->
        {:ok, ttl * 3600}

      {ttl, "d"} ->
        {:ok, ttl * 86400}

      _ ->
        {:error, {:invalid, :ttl}}
    end
  end

  defp on_created(conn, id, ttl) do
    case get_format(conn) do
      "html" ->
        conn
        |> save_secret_id(id)
        |> save_default_ttl(ttl)
        |> put_flash(:info, "Your secret was securely saved.")
        |> redirect(to: Routes.secret_path(conn, :preview, id))

      _ ->
        conn
        |> put_status(201)
        |> put_resp_header("x-secret-ttl", to_string(ttl))
        |> text(Routes.secret_url(conn, :preview, id) <> "\n")
    end
  end

  @error_messages %{
    secret: "Secret can't be blank",
    ttl: "TTL is invalid"
  }

  defp on_invalid(conn, field) do
    case get_format(conn) do
      "html" ->
        conn
        |> put_status(422)
        |> assign(:error, @error_messages[field])
        |> new(%{})

      _ ->
        conn
        |> put_status(422)
        |> text("Error: #{@error_messages[field]}")
    end
  end

  def preview(conn, %{"id" => id}) do
    url = Routes.secret_url(conn, :preview, id)

    if Secrets.get_secret(id) do
      conn
      |> assign_active_secret_ids()
      |> render("preview.html", id: id, url: url)
    else
      not_found(conn)
    end
  end

  def reveal(conn, %{"id" => id}) do
    if text = Secrets.get_secret(id) do
      Secrets.burn_secret!(id)
      render(conn, "show.html", secret: text)
    else
      not_found(conn)
    end
  end

  defp not_found(conn) do
    conn
    |> put_status(404)
    |> render("not_found.html")
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
    case conn.cookies["default_ttl"] do
      nil ->
        Application.fetch_env!(:flash, :default_ttl)

      ttl ->
        String.to_integer(ttl)
    end
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
