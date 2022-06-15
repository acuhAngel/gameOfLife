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
        display: "Board size: 5 x 5",
        board: Grid.new(5, "0"),
        size: 5,
        go: "stop",
        probability: "0.6",
        steps: ""
      )
    }
  end

  def render(assigns), do: PageView.render("gol.html", assigns)

  @doc """
  #handle_event("probability", %{"value" => p}, socket)
  esta funcion toma del html el valor del range para generar los tableros nuevos al dar randomize, si esta el programa corriendo retornara solo go: "go"

  #handle_event("dimension", %{"dimension" => dimension}, socket)
  esta funcion toma el valor del menu de radios y genera un tablero limpio, si esta el programa corriendo retornara solo go: "go"

  #handle_event("randomize", _, socket)
  genera un tablero del tamaño y con la probabilidad que se manda desde el html, si esta el programa corriendo retornara solo go: "go"

  #handle_event("go", _, socket)
  inicia el ciclo de ejecucion donde se ira actualizando el tablero a partir de ltablero actual

  """
  def handle_event("probability", %{"value" => p}, socket) do
    if socket.assigns.go == "stop" do
      GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{probability: p})

      {
        :noreply,
        assign(
          socket,
          probability: p
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          go: "go"
        )
      }
    end
  end

  def handle_event("dimension", %{"dimension" => dimension}, socket) do
    if socket.assigns.go == "stop" do
      IO.inspect(dimension)
      display = "Board size: #{dimension} x #{dimension}"
      {size, _} = Integer.parse(dimension)
      board = Grid.new(size, "0")

      GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
        display: display,
        size: size,
        board: board
      })

      {
        :noreply,
        assign(
          socket,
          display: display,
          size: size,
          steps: "",
          board: board
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          go: "go"
        )
      }
    end
  end

  def handle_event("randomize", _, socket) do
    if socket.assigns.go == "stop" do
      display = "randomizing"
      board = Grid.new(socket.assigns.size, socket.assigns.probability)

      GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
        display: display,
        board: board,
        steps: ""
      })

      {
        :noreply,
        assign(
          socket,
          display: display,
          board: board,
          steps: ""
        )
      }
    else
      {
        :noreply,
        assign(
          socket,
          go: "go"
        )
      }
    end
  end

  def handle_event("go", _, socket) do
    # size = socket.assigns.size
    Process.send_after(self(), :update, 1000)
    board = socket.assigns.board |> Grid.next()

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
      board: board,
      display: "step",
      steps: 0,
      go: "go"
    })

    {
      :noreply,
      assign(
        socket,
        # size: size,
        board: board,
        go: "go",
        steps: 0,
        display: "step"
      )
    }
  end

  def handle_event("stop", _, socket) do
    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
      go: "stop",
      board: socket.assigns.board
    })

    {
      :noreply,
      assign(
        socket,
        go: "stop"
      )
    }
  end

  def handle_event("chg-status", data, socket) do
    # |> IO.inspect
    r = data["row"] |> String.to_integer()
    # |> IO.inspect
    c = data["col"] |> String.to_integer()
    # |> IO.inspect
    v = data["value"]
    g = socket.assigns.board.data

    board = Grid.change(g, r, c, v)

    GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
      board: board

    })

    {
      :noreply,
      assign(
        socket,
        board: board
      )
    }
  end

  # * se encarga de mantener el ciclo constante actualizando cada 1000 ms
  def handle_info(:update, socket) do
    board_n = socket.assigns.board
    board_y = board_n |> Grid.next()
    steps = socket.assigns.steps + 1

    if socket.assigns.go == "go" do
      IO.puts("iterando")
      Process.send_after(self(), :update, 1000)

      GameOfLifeWeb.Endpoint.broadcast_from(self(), @topic, "board_update", %{
        board: board_y,
        steps: steps,
        probability: socket.assigns.probability
      })

      {:noreply,
       assign(socket,
         board: board_y,
         steps: steps,
         display: socket.assigns.display,
         probability: socket.assigns.probability
       )}
    else
      IO.puts("Stop")
      {:noreply, assign(socket, board: board_n)}
    end
  end

  def handle_info(info, socket) do
    {:noreply, assign(socket, info.payload)}
  end
end
