defmodule FlashWeb.SecretControllerTest do
  use FlashWeb.ConnCase

  test "sharing a secret" do
    conn_1 = get(build_conn(), "/")

    assert html_response(conn_1, 200) =~ ~r/create secret link/i

    conn_1 = post(conn_1, "/", secret: %{text: " ", ttl: "3600"})

    assert html_response(conn_1, 422) =~ ~r/create secret link/i

    conn_1 = post(conn_1, "/", secret: %{text: "hush hush", ttl: "3600"})

    secret_url = redirected_to(conn_1, 302)

    conn_1 = get(conn_1, secret_url)

    assert html_response(conn_1, 200) =~ ~r/saved/i

    conn_2 = get(build_conn(), secret_url)

    assert html_response(conn_2, 200) =~ ~r/reveal/i

    conn_2 = post(conn_2, secret_url)

    assert html_response(conn_2, 200) =~ ~r/hush hush/i

    conn_2 = post(conn_2, secret_url)

    assert html_response(conn_2, 404)

    conn_2 = get(conn_2, secret_url)

    assert html_response(conn_2, 404)

    conn_1 = get(conn_1, secret_url)

    assert html_response(conn_1, 404)
  end
end
