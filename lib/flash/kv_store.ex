defmodule Flash.KvStore do
  @callback child_spec() :: Supervisor.child_spec()
  @callback put(key :: binary, value :: binary, ttl :: integer) :: :ok
  @callback get(key :: binary) :: binary | nil
  @callback delete(key :: binary) :: :ok
end
