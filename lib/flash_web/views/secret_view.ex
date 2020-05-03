defmodule FlashWeb.SecretView do
  use FlashWeb, :view

  def cmd_key_available?(conn) do
    with {_, user_agent} <- List.keyfind(conn.req_headers, "user-agent", 0),
         true <- String.contains?(user_agent, "Macintosh") do
      true
    else
      _ -> false
    end
  end
end
