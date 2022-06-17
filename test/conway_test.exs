defmodule ConwayTest do
  use ExUnit.Case
  alias Conway.Grid
  @grid %Conway.Grid{data: {{0,0,1,1,0},{1,0,1,1,1},{0,1,1,0,0},{1,0,1,0,1},{0,1,0,0,0}}}

  test "new(size, p)" do
    assert Grid.new(3, "0") ==  %Conway.Grid{data: {{0,0,0},{0,0,0},{0,0,0}}}
    assert Grid.new(3, "1") ==  %Conway.Grid{data: {{1,1,1},{1,1,1},{1,1,1}}}
  end

  test "new data list" do
    assert Grid.new([[0,0,1,1,0],[1,0,1,1,1],[0,1,1,0,0],[1,0,1,0,1],[0,1,0,0,0]]) == @grid
  end

  test "size data " do
    s = Grid.size(@grid)
    assert s == 5
  end

  test "cell status " do
    c1 = Grid.cell_status(@grid,0 ,0)
    c2 = Grid.cell_status(@grid,2 ,2)
    assert  c1 == 0
    assert  c2 == 1
  end

  test "next " do
    n = Grid.next(@grid)
    assert n.data == {{0,1,1,0,1},{0,0,0,0,1},{1,0,0,0,1},{1,0,1,1,0},{0,1,0,0,0}}
  end

  test "list to data " do
    a = Grid.list_to_data([[0,1,0],[1,1,1],[0,0,0]])
    assert a == {{0,1,0},{1,1,1},{0,0,0}}
  end

  test "nex cell status live with 2 neighbours" do
    case_1 = Conway.Grid.next_cell_status(@grid, 0, 3)


    assert case_1  == 1



  end

  test "nex cell status live with 3 neighbours" do
    case_3 = Conway.Grid.next_cell_status(@grid, 0, 2)
    assert case_3  == 1
  end

  test "nex cell status death with 3 neighbours" do
    case_3 = Conway.Grid.next_cell_status(@grid, 0, 2)
    assert case_3  == 1
  end

  test "alive neighbours" do
    n = Conway.Grid.alive_neighbours(@grid,1,1)
    assert n == 5
  end

  test "change status" do
    c1 = Conway.Grid.change(@grid.data, 0,3,"1")
    c2 = Conway.Grid.change(@grid.data, 0,0,"0")
    assert c1 == %Conway.Grid{data: {{0,0,1,0,0},{1,0,1,1,1},{0,1,1,0,0},{1,0,1,0,1},{0,1,0,0,0}}}
    assert c2 == %Conway.Grid{data: {{1,0,1,1,0},{1,0,1,1,1},{0,1,1,0,0},{1,0,1,0,1},{0,1,0,0,0}}}
  end

  # Conway.TerminalGame

  test "play without board" do

    assert Conway.TerminalGame.play("","",0) == :ok

  end

  test "play" do

    assert Conway.TerminalGame.play(@grid,"test",1) == :ok

  end


end
