defmodule Splendor.Acceptor do
  require Logger
  use Task, restart: :permanent

  @spec start_link(atom) :: {:ok, pid}
  def start_link(name) do
    Task.start_link(__MODULE__, :init, [name])
  end

  @spec init(atom) :: no_return()
  def init(name) do
    port = 8484
    options = [
      :binary,
      active: :once,
      reuseaddr: true,
    ]
    {:ok, listen_sock} = :gen_tcp.listen(port, options)
    Logger.info("Accepting connections on port #{port}")
    accept(name, listen_sock)
  end

  @spec accept(atom, :gen_tcp.listenSocket) :: no_return()
  def accept(name, listen_sock) do
    {:ok, socket} = :gen_tcp.accept(listen_sock)
    Logger.info("Connection accepted")
    DynamicSupervisor.start_child(Splendor.SessionSupervisor, {Splendor.Session, [socket]}) |> spawn(socket)
    accept(name, listen_sock)
  end

  defp spawn({:ok, process}, socket) do
    :ok = :gen_tcp.controlling_process(socket, process)
    Logger.info("Spawned session")
  end

  defp spawn({:error, error}, _) do
    Logger.warn("Failed to spawn process: #{error |> inspect()}")
  end
end
