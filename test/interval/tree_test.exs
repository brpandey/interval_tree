defmodule Interval.Tree.Test do
  use ExUnit.Case, async: true

  alias Interval.Tree


  describe "interval insertions" do

    test "no insertion, empty tree" do

      tree = Tree.new
      assert "#IntervalTree<{0, nil}>" == "#{inspect tree}"
      
    end
    
    
    test "single insertion" do
      
      value = Interval.new({23,34})
      tree = Tree.new |> Tree.insert(value)
      
      assert "#IntervalTree<{1, {23..34, 34, nil, nil}}>" = "#{inspect tree}"

    end
    
    
    test "multiple insertions, right skew" do

      value1 = Interval.new({23,34})
      value2 = Interval.new({26,76})
      value3 = Interval.new({32,40})
      value4 = Interval.new({34,36})

      tree = 
        Tree.new 
        |> Tree.insert(value1)
        |> Tree.insert(value2)
        |> Tree.insert(value3)
        |> Tree.insert(value4)
      
      assert "#IntervalTree<{4, {23..34, 76, nil, {26..76, 76, nil, {32..40, 40, nil, {34..36, 36, nil, nil}}}}}>" =  "#{inspect tree}"

    end


    test "multiple insertions, left skew" do

      value1 = Interval.new({23,34})
      value2 = Interval.new({26,76})
      value3 = Interval.new({32,40})
      value4 = Interval.new({34,36})

      tree = 
        Tree.new 
        |> Tree.insert(value4)
        |> Tree.insert(value3)
        |> Tree.insert(value2)
        |> Tree.insert(value1)
      
      assert "#IntervalTree<{4, {34..36, 76, {32..40, 76, {26..76, 76, {23..34, 34, nil, nil}, nil}, nil}, nil}}>" =  "#{inspect tree}"

    end


    test "multiple insertions, less skew" do

      value1 = Interval.new({23,34})
      value2 = Interval.new({26,76})
      value3 = Interval.new({32,40})
      value4 = Interval.new({34,36})

      tree = 
        Tree.new 
        |> Tree.insert(value2)
        |> Tree.insert(value3)
        |> Tree.insert(value1)
        |> Tree.insert(value4)
      
      assert "#IntervalTree<{4, {26..76, 76, {23..34, 34, nil, nil}, {32..40, 40, nil, {34..36, 36, nil, nil}}}}>" =  "#{inspect tree}"

    end

    
  end


  describe "interval search" do

    setup :setup_tree

    test "unsuccessful search", %{tree: tree} do

      key = Interval.new({4,5})
      result = Tree.search(tree, key)

      assert [] == result |> MapSet.to_list
    end


    test "successful search, single overlap", %{tree: tree} do

      key = Interval.new({22,24})
      result = Tree.search(tree, key)

      list = [15..23]

      assert "#{inspect list}" == "#{inspect MapSet.to_list(result)}"
    end


    test "successful search, multiple overlaps", %{tree: tree} do

      key = Interval.new({18,20})
      result = Tree.search(tree, key)

      list = [17..19, 19..20, 16..21, 15..23]

      assert "#{inspect list}" == "#{inspect MapSet.to_list(result)}"

    end


  end


  describe "interval traversal" do

    setup :setup_tree

    test "inorder traversal", %{tree: tree} do

      list = ["0..3", "5..8", "6..10", "8..9", "15..23", "16..21", "17..19",
             "19..20", "25..30", "26..27"]

      assert list == Tree.traverse(tree)
    end

  end



  defp setup_tree(_context) do
    intervals = [{16, 21}, {8, 9}, {15, 23}, {25, 30}, {17, 19}, {5,8}, 
                 {6,10}, {0,3}, {26, 27}, {19, 20}]
    
    tree = 
      Enum.reduce(intervals, Tree.new, fn {start, finish}, tree_acc ->
        Tree.insert(tree_acc, Interval.new({start, finish}))
      end)
      
    [tree: tree]
  end
  

end
