defmodule GameOfLifeWeb.GameOfLifeLive do
  @moduledoc """

  """
  use Phoenix.LiveView
  alias Conway.Grid
  alias GameOfLifeWeb.PageView

  def mount(_params, _session, socket) do
    # connected?(socket) |> IO.inspect
    # if connected?(socket), do: Process.send_after(self(), :update, 10000, true)
    {
      :ok,
      assign(
        socket,
        display: "",
        board: %Conway.Grid{data: {{1, 1}, {0, 0}}},
        size: 10,
        data: "{1,1,1,0}",
        go: ""
      )
    }
  end

  def render(assigns), do: PageView.render("gol.html", assigns)

  def handle_event("randomize", _, socket) do
    display = "randomizing"
    # |> IO.inspect
    board = Grid.new(socket.assigns.size)


    # data = board.data  |> Tuple.to_list |> Enum.map(fn x -> Tuple.to_list(x) end) |> Enum.map(fn x -> x |> Enum.join  end ) |> IO.inspect

    {
      :noreply,
      assign(
        socket,
        display: display,
        board: board
        # data: data
      )
    }
  end

  def handle_event("dimension", %{"dimension" => dimension}, socket) do
    IO.inspect(dimension)
    display = "Board size: #{dimension} x #{dimension}  "
    {size, _} = Integer.parse(dimension)
    board = Grid.new(size)

    {
      :noreply,
      assign(
        socket,
        display: display,
        size: size,
        board: board
      )
    }
  end

  def handle_event("go", _, socket) do
    size = socket.assigns.size
    Process.send_after(self(), :update, 1000)
    board = socket.assigns.board |> Grid.next()

    {
      :noreply,
      assign(
        socket,
        size: size,
        board: board,
        go: :ok
      )
    }
  end

  def handle_event("stop", _, socket) do
    {
      :noreply,
      assign(
        socket,
        go: ""
        )
    }
  end


  def handle_info(:update, socket) do
    board = socket.assigns.board

    if socket.assigns.go == :ok do
      IO.puts("repito")
      Process.send_after(self(), :update, 1000)
      {:noreply, assign(socket, board: board |> Grid.next())}
    else
      IO.puts("no iniciado")
      {:noreply, assign(socket, board: board)}
    end
  end
end
