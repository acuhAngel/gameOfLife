defmodule GameOfLifeWeb.GameOfLifeLive do
  @moduledoc """

  """
  use Phoenix.LiveView
  alias Conway.Grid
  alias GameOfLifeWeb.PageView

  @topic "GOL"

  def mount(_params, _session, socket) do
    GameOfLifeWeb.Endpoint.subscribe(@topic)

    {
      :ok,
      assign(
        socket,
        display: "",
        board: %Conway.Grid{data: {{1, 1}, {0, 0}}},
        size: 10,
        data: "{1,1,1,0}",
        go: "",
        probability: "0.6",
        steps: ""
      )
    }
  end

  def render(assigns), do: PageView.render("gol.html", assigns)

  def handle_event("probability", %{"value" => p}, socket) do
    {
      :noreply,
      assign(
        socket,
        probability: p
      )
    }
  end

  def handle_event("dimension", %{"dimension" => dimension}, socket) do
    IO.inspect(dimension)
    display = "Board size: #{dimension} x #{dimension}  "
    {size, _} = Integer.parse(dimension)
    board = Grid.new(size, socket.assigns.probability)
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{board: board, display: display,
    size: size})
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

  def handle_event("randomize", _, socket) do
    display = "randomizing"
    board = Grid.new(socket.assigns.size, socket.assigns.probability)
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{display: display, board: board})
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

  def handle_event("go", _, socket) do
    # size = socket.assigns.size
    Process.send_after(self(), :update, 1000)
    board = socket.assigns.board |> Grid.next()
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{board: board, display: "steps", steps: 0, go: :ok,})
    {
      :noreply,
      assign(
        socket,
        # size: size,
        board: board,
        go: :ok,
        steps: 0,
        display: "steps"
      )
    }
  end

  def handle_event("stop", _, socket) do
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{go: "", board: socket.assigns.board})
    {
      :noreply,
      assign(
        socket,
        go: ""
      )
    }
  end

  def handle_info(%{topic: @topic, payload: payload}, socket) do
    {:noreply, assign(socket, :board, payload.board)}
  end

  # * se encarga de mantener el ciclo constante actualizando cada 1000 ms
  def handle_info(:update, socket) do
    board_n = socket.assigns.board
    board_y = board_n |> Grid.next()
    steps = socket.assigns.steps + 1

    if socket.assigns.go == :ok do
      IO.puts("iterando")
      Process.send_after(self(), :update, 1000)
      GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{board: board_y, steps: steps})
      {:noreply, assign(socket, board: board_y, steps: steps)}
    else
      IO.puts("Stop")
      {:noreply, assign(socket, board: board_n)}
    end
  end
end
