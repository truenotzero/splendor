defmodule Splendor.Util do
  @moduledoc """
  A module for useful functions
  """

  @doc """
  Fetches the config for the current module.

  For example, if the current module is `Foo`, then this is equivalent to `Application.fetch_env!(:frontend, Foo)`
  """
  defmacro fetch_module_config!() do
    quote do
      Application.fetch_env!(:frontend, __MODULE__)
    end
  end
end
