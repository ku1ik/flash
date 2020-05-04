defmodule FlashWeb.SecretControllerTest do
  use FlashWeb.ConnCase

  describe "sharing a secret" do
    test "html format requests (browser)" do
      conn_1 = get(build_conn(), "/")

      assert html_response(conn_1, 200) =~ ~r/create secret link/i

      conn_1 = post(conn_1, "/", secret: " ", ttl: "3600")

      assert html_response(conn_1, 422) =~ ~r/create secret link/i

      conn_1 = post(conn_1, "/", secret: "hush hush", ttl: "3600")

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

    test "text format requests (curl etc)" do
      # Example usage with curl, with reading of secret from STDIN:
      #   curl -s -F 'secret=<-' -F ttl=3600 http://localhost:4000\?_format=text

      conn = post(build_conn(), "/?_format=text", secret: " ")

      assert text_response(conn, 422) =~ ~r/blank/i

      conn = post(build_conn(), "/?_format=text", secret: "hush hush")

      assert text_response(conn, 201) =~ ~r/^http:/i
      assert ttl_header(conn) == 3600

      for {ttl, secs} <- [{"60", 60}, {"30s", 30}, {"2m", 120}, {"3h", 10800}, {"4d", 345600}] do
        conn = post(build_conn(), "/?_format=text", secret: "hush hush", ttl: ttl)

        assert text_response(conn, 201) =~ ~r/^http:/i
        assert ttl_header(conn) == secs
      end
    end

    defp ttl_header(conn) do
      with {_, ttl} <- List.keyfind(conn.resp_headers, "x-secret-ttl", 0) do
        String.to_integer(ttl)
      end
    end
  end
end
