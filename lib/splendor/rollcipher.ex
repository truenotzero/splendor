defmodule Splendor.RollCipher do
  @moduledoc """
  Implements the roll cipher obfuscation
  This should always be used on the ciphertext
  """

  import Bitwise

  @doc """
  Applies roll cipher obfuscation to a piece of ciphertext
  Use before cipher encryption
  """
  @spec encrypt(binary()) :: binary()
  def encrypt(data) do
    size = byte_size(data)
    data = data |> :binary.bin_to_list()
    0..2 |> Enum.reduce(data, fn _, data ->
      data
      |> Enum.reduce({0, size, []}, fn e, {prev, delta, data} ->
        e = e |> rol(3)
        e = (e + delta) &&& 0xFF
        e = e ^^^ prev
        temp = e
        e = e |> ror(delta)
        e = (~~~e) &&& 0xFF
        e = (e + 0x48) &&& 0xFF
        {temp, delta - 1, [e | data]}
      end)
      |> elem(2) # selects `data` from {prev, delta, data}
      |> Enum.reduce({0, size, []}, fn e, {prev, delta, data} ->
        e = e |> rol(4)
        e = (e + delta) &&& 0xFF
        e = e ^^^ prev
        temp = e
        e = e ^^^ 0x13
        e = e |> ror(3)
        {temp, delta - 1, [e | data]}
      end)
      |> elem(2) # selects `data` from {prev, delta, data}
    end)
    |> :binary.list_to_bin()
  end

  @doc """
  Removes roll cipher obfuscation from a piece of ciphertext
  Use after cipher decryption
  """
  @spec decrypt(binary()) :: binary()
  def decrypt(data) do
    size = byte_size(data)
    data = data |> :binary.bin_to_list() |> Enum.reverse()
    0..2 |> Enum.reduce(data, fn _, data ->
      data
      |> Enum.reduce({0, size, []}, fn e, {prev, delta, data} ->
        e = e |> rol(3)
        e = e ^^^ 0x13
        temp = e
        e = e ^^^ prev
        e = (e - delta) &&& 0xFF
        e = e |> ror(4)
        {temp, delta - 1, [e | data]}
      end)
      |> elem(2) # selects `data` from {prev, delta, data}
      |> Enum.reduce({0, size, []}, fn e, {prev, delta, data} ->
        e = (e - 0x48) &&& 0xFF
        e = (~~~e) &&& 0xFF
        e = e |> rol(delta)
        temp = e
        e = e ^^^ prev
        e = (e - delta) &&& 0xFF
        e = e |> ror(3)
        {temp, delta - 1, [e | data]}
      end)
      |> elem(2) # selects `data` from {prev, delta, data}
    end)
    |> Enum.reverse()
    |> :binary.list_to_bin()
  end

  defp rol(b, count) do
    count = count |> rem(8)
    hi = b <<< count
    lo = b >>> (8 - count)
    (hi ||| lo) &&& 0xFF
  end

  defp ror(b, count) do
    count = count |> rem(8)
    hi = b <<< (8 - count)
    lo = b >>> count
    (hi ||| lo) &&& 0xFF
  end
end
