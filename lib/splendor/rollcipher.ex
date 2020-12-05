defmodule Splendor.RollCipher do
  @moduledoc """
  Implements the roll cipher obfuscation
  This should always be used on the ciphertext
  """


  @doc """
  Applies roll cipher obfuscation to a piece of ciphertext
  Use after cipher encryption
  """
  @spec encrypt(binary()) :: binary()
  def encrypt(data) do
    data
  end

  @doc """
  Removes roll cipher obfuscation from a piece of ciphertext
  Use before cipher decryption
  """
  @spec decrypt(binary()) :: binary()
  def decrypt(data) do
    data
  end
end
