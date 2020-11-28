defmodule Splendor.Session do
  require Logger
  use GenServer, restart: :temporary

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init([socket]) do
    Kernel.send(self(), :handshake)
    {:ok, [socket: socket]}
  end

  @impl GenServer
  def handle_info(:handshake, state) do
    import Splendor.PacketBuffer
    packet = <<>>
      |> push16(95) # GameVer
      |> pushstr("1") # SubVer
      |> push32(0xDEAD)
      |> push32(0xBEEF)
      |> push8(8)
      |> finalize()
      |> IO.inspect(label: "the hello packet")
    case :gen_tcp.send(state[:socket], packet) do
      :ok ->
        Logger.info("Sent handshake")
        {:noreply, state}
      {:error, reason} ->
        Logger.warn("Failed to send handshake: #{inspect(reason)}")
        {:stop, :normal, state}
    end
  end

  @impl GenServer
  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("Closing session gracefully")
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.info("Unknown message: #{inspect(msg)}")
    case msg do
      {:tcp, socket, _} -> :inet.setopts(socket, active: :once)
    end
    {:noreply, state}
  end
end
