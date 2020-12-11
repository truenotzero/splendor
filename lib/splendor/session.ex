defmodule Splendor.Session do
  @moduledoc """
  Represents the server's connection with the client
  """

  require Logger
  use GenServer, restart: :temporary

  @header_size 4

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init([socket]) do
    Kernel.send(self(), :handshake)
    {:ok, %{socket: socket, buffer: <<>>, step: :parse_header, sz: 0, cipher: nil}}
  end

  @impl GenServer
  def handle_info(:handshake, state) do
    import Splendor.PacketBuffer
    import Splendor.Util

    opts = fetch_module_config!()

    cipher = Splendor.Cipher.new(opts[:major])

    packet = <<>>
      |> push16(opts[:major]) # GameVer
      |> pushstr(opts[:minor]) # SubVer
      |> pushbin(cipher.recv.iv)
      |> pushbin(cipher.send.iv)
      |> push8(opts[:locale])
      |> finalize()

    state = %{state | cipher: cipher}

    case :gen_tcp.send(state.socket, packet) do
      :ok ->
        Logger.info("Sent handshake")
        {:noreply, state}
      {:error, reason} ->
        Logger.warn("Failed to send handshake: #{inspect(reason)}")
        {:stop, :normal, state}
    end
  end

  @impl GenServer
  def handle_info({:tcp, _socket, data}, state) do
    Logger.info("Got some data")
    {:noreply, %{state | buffer: state.buffer <> data}, {:continue, state.step}}
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

  @impl GenServer
  def handle_continue(:parse_header, state) do
    if byte_size(state.buffer) < @header_size do
      Logger.info("Too little data to parse header")
      {:noreply, state, {:continue, :await_data}}
    else
      <<header::binary-size(4), rest::binary>> = state.buffer
      case Splendor.Cipher.validate_header(header, state.cipher) do
        {:ok, sz} ->
          Logger.info("Expecting body of length #{sz}")
          {:noreply, %{state | sz: sz, buffer: rest, step: :parse_body}, {:continue, :parse_body}}
        {:error, err} ->
          Logger.warn("Failed to validate header (#{err}), closing connection")
          {:stop, :normal, state}
      end
    end
  end

  @impl GenServer
  def handle_continue(:parse_body, state) do
    if byte_size(state.buffer) < state.sz do
      Logger.info("Too little data to parse body")
      {:noreply, state, {:continue, :await_data}}
    else
      sz = state.sz
      <<data::binary-size(sz), buffer::binary>> = state.buffer
      {data, cipher} = data |> Splendor.Cipher.decrypt(state.cipher)
      #TODO: Do something with this data (dispatch it!)
      Logger.info("Packet: #{inspect(data)}")
      {:noreply, %{state | cipher: cipher, sz: @header_size, buffer: buffer, step: :parse_header}, {:continue, :await_data}}
    end
  end

  @impl GenServer
  def handle_continue(:await_data, state) do
    :inet.setopts(state.socket, active: :once)
    {:noreply, state}
  end
end
