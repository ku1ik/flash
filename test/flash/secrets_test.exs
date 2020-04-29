defmodule Flash.SecretsTest do
  use ExUnit.Case

  describe "secrets" do
    alias Flash.Secrets

    test "add_secret/2 returns ID of created secret" do
      assert {:ok, id} = Secrets.add_secret("sauce1", 5)
      assert is_binary(id)
    end

    test "add_secret/2 returns error when secret is blank or too big" do
      assert {:error, :invalid} = Secrets.add_secret("", 5)
      assert {:error, :invalid} = Secrets.add_secret(" ", 5)

      big_secret = Stream.cycle(['.']) |> Enum.take(100_000) |> List.to_string()
      assert {:error, :invalid} = Secrets.add_secret(big_secret, 5)
    end

    test "get_secret/1 returns nil for non-existing secret" do
      assert Secrets.get_secret("a1b2c3") == nil
    end

    test "get_secret/1 returns secret content before TTL expires" do
      {:ok, id} = Secrets.add_secret("sauce2", 5)

      assert Secrets.get_secret(id) == "sauce2"
    end

    test "get_secret/1 returns nil for expired secret" do
      {:ok, id} = Secrets.add_secret("sauce3", 1)
      :timer.sleep(1500)

      assert Secrets.get_secret(id) == nil
    end

    test "get_secret/1 returns nil for deleted secret" do
      {:ok, id} = Secrets.add_secret("sauce4", 5)
      Secrets.burn_secret!(id)

      assert Secrets.get_secret(id) == nil
    end
  end
end
