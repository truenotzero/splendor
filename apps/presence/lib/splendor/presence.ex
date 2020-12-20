defmodule Splendor.Presence do
  @moduledoc """
  The presence core is used for tracking online players
  """

  @typedoc """
  Tracks the current stage the player is connected to
  Could be `login`, `game` or `shop`
  """
  @spec stage :: atom()
  @spec info :: any()
  @spec t :: :offline | {:online, stage(), info()}

  @doc """
  Locates a player by their account id
  """
  @spec locate_account(non_neg_integer()) :: t()
  def locate_account(account_id) do
    :todo
  end

  @doc """
  Locates a player by their ip address
  """
  @spec locate_ip(:inet.ip_address()) :: t()
  def locate_ip(ip_addr) do
    :todo
  end
end
