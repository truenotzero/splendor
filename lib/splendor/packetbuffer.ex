defmodule Splendor.PacketBuffer do
  def push8(buffer, n) do
    buffer <> <<n::8>>
  end

  def push16(buffer, n) do
    buffer <> <<n::16-little>>
  end

  def push32(buffer, n) do
    buffer <> <<n::32-little>>
  end

  def push64(buffer, n) do
    buffer <> <<n::64-little>>
  end

  def pushstr(buffer, str) do
    push16(buffer, byte_size(str)) <> str
  end

  def send(buffer) do
    <<byte_size(buffer)::16-little>> <> buffer
  end
end
