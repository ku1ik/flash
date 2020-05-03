defmodule Flash.Secrets.Store do
  @callback child_spec() :: Supervisor.child_spec()
  @callback put_secret(id :: binary, value :: binary, ttl :: integer) :: :ok
  @callback get_secret(id :: binary) :: binary | nil
  @callback delete_secret(id :: binary) :: :ok
end
