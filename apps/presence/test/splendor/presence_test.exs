defmodule Splendor.PresenceTest do
  use ExUnit.Case
  doctest Splendor.Presence

  test "greets the world" do
    assert Splendor.Presence.hello() == :world
  end
end
