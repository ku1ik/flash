defmodule FlashWeb.SecretView do
  use FlashWeb, :view

  def cmd_key_available?(conn), do: macos?(conn)

  def copy_tool(conn) do
    if macos?(conn), do: "pbcopy", else: "xclip"
  end

  def copy_cmd(conn) do
    if macos?(conn), do: "pbcopy", else: "xclip -selection clipboard"
  end

  defp macos?(conn) do
    with {_, user_agent} <- List.keyfind(conn.req_headers, "user-agent", 0),
         true <- String.contains?(user_agent, "Macintosh") do
      true
    else
      _ -> false
    end
  end
end
