defmodule ConwayTest do
  use ExUnit.Case
  alias Conway.Grid
  @grid %Conway.Grid{data: {{0,0,1},{1,0,1},{0,1,1}}}

  test "new(size, p)" do
    assert Grid.new(3, "0") ==  %Conway.Grid{data: {{0,0,0},{0,0,0},{0,0,0}}}
    assert Grid.new(3, "1") ==  %Conway.Grid{data: {{1,1,1},{1,1,1},{1,1,1}}}
  end

  test "new data list" do
    assert Grid.new([[0,0,1],[1,0,1],[0,1,1]]) == @grid
  end

  test "size data " do
    s = Grid.size(@grid)
    assert s == 3
  end

  test "cell status " do
    c1 = Grid.cell_status(@grid,0 ,0)
    c2 = Grid.cell_status(@grid,2 ,2)
    assert  c1 == 0
    assert  c2 == 1
  end

end
