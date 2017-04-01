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

      # before avl implemented
      # assert "#IntervalTree<{4, {23..34, 76, nil, {26..76, 76, nil, {32..40, 40, nil, {34..36, 36, nil, nil}}}}}>" =  "#{inspect tree}"

      # after avl implemented
      assert "#IntervalTree<{4, {26..76, 76, {23..34, 34, nil, nil}, {32..40, 40, nil, {34..36, 36, nil, nil}}}}>" =  "#{inspect tree}"

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
      
      # before avl implemented
      # assert "#IntervalTree<{4, {34..36, 76, {32..40, 76, {26..76, 76, {23..34, 34, nil, nil}, nil}, nil}, nil}}>" =  "#{inspect tree}"

      # after avl implemented
      assert "#IntervalTree<{4, {32..40, 76, {26..76, 76, {23..34, 34, nil, nil}, nil}, {34..36, 36, nil, nil}}}>" =  "#{inspect tree}"

    end


    test "multiple insertions, right-left skew" do

      value1 = Interval.new({23,34})
      value2 = Interval.new({26,76})
      value3 = Interval.new({32,40})
      value4 = Interval.new({28,35})
      value5 = Interval.new({34,36})
      value6 = Interval.new({26,55})

      tree = 
        Tree.new 
        |> Tree.insert(value1)
        |> Tree.insert(value2)
        |> Tree.insert(value3)
        |> Tree.insert(value4)
        |> Tree.insert(value5)
        |> Tree.insert(value6)

      assert "#IntervalTree<{6, {28..35, 76, {26..76, 76, {23..34, 34, nil, nil}, {26..55, 55, nil, nil}}, {32..40, 40, nil, {34..36, 36, nil, nil}}}}>" =  "#{inspect tree}"

    end


    test "multiple insertions, left-right skew" do

      value1 = Interval.new({32,40})
      value2 = Interval.new({26,55})
      value3 = Interval.new({34,36})
      value4 = Interval.new({23,34})
      value5 = Interval.new({26,76})
      value6 = Interval.new({28,35})


      tree = 
        Tree.new 
        |> Tree.insert(value1)
        |> Tree.insert(value2)
        |> Tree.insert(value3)
        |> Tree.insert(value4)
        |> Tree.insert(value5)
        |> Tree.insert(value6)

      assert "#IntervalTree<{6, {26..76, 76, {26..55, 55, {23..34, 34, nil, nil}, nil}, {32..40, 40, {28..35, 35, nil, nil}, {34..36, 36, nil, nil}}}}>" == "#{inspect tree}"

    end



    test "multiple insertions, already balanced" do

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

    test "multiple insertions, checking each step" do

      value1 = Interval.new({16, 21})
      value2 = Interval.new({8, 9})
      value3 = Interval.new({15, 23})
      value4 = Interval.new({25, 30})
      value5 = Interval.new({17, 19})
      value6 = Interval.new({5,8})
      value7 = Interval.new({6,10}) 
      value8 = Interval.new({0,3})
      value9 = Interval.new({26, 27})
      value10 = Interval.new({19, 20})

      tree = Tree.new

      tree = Tree.insert(tree, value1)
      assert "#IntervalTree<{1, {16..21, 21, nil, nil}}>" = "#{inspect tree}"

      tree = Tree.insert(tree, value2)
      assert "#IntervalTree<{2, {16..21, 21, {8..9, 9, nil, nil}, nil}}>" = "#{inspect tree}"

      # we do a left-right rotate
      tree = Tree.insert(tree, value3)
      assert "#IntervalTree<{3, {15..23, 23, {8..9, 9, nil, nil}, {16..21, 21, nil, nil}}}>" = "#{inspect tree}"

      tree = Tree.insert(tree, value4)
      assert "#IntervalTree<{4, {15..23, 30, {8..9, 9, nil, nil}, {16..21, 30, nil, {25..30, 30, nil, nil}}}}>" = "#{inspect tree}"

      # we do a right-left rotate
      tree = Tree.insert(tree, value5)
      assert "#IntervalTree<{5, {15..23, 30, {8..9, 9, nil, nil}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, nil, nil}}}}>" = "#{inspect tree}"


      tree = Tree.insert(tree, value6)
      assert "#IntervalTree<{6, {15..23, 30, {8..9, 9, {5..8, 8, nil, nil}, nil}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, nil, nil}}}}>" = "#{inspect tree}"


      # we do a left-right rotate
      tree = Tree.insert(tree, value7)
      assert "#IntervalTree<{7, {15..23, 30, {6..10, 10, {5..8, 8, nil, nil}, {8..9, 9, nil, nil}}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, nil, nil}}}}>" = "#{inspect tree}"

      tree = Tree.insert(tree, value8)
      assert "#IntervalTree<{8, {15..23, 30, {6..10, 10, {5..8, 8, {0..3, 3, nil, nil}, nil}, {8..9, 9, nil, nil}}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, nil, nil}}}}>" = "#{inspect tree}"


      tree = Tree.insert(tree, value9)
      assert "#IntervalTree<{9, {15..23, 30, {6..10, 10, {5..8, 8, {0..3, 3, nil, nil}, nil}, {8..9, 9, nil, nil}}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, nil, {26..27, 27, nil, nil}}}}}>" = "#{inspect tree}"


      tree = Tree.insert(tree, value10)
      assert "#IntervalTree<{10, {15..23, 30, {6..10, 10, {5..8, 8, {0..3, 3, nil, nil}, nil}, {8..9, 9, nil, nil}}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, {19..20, 20, nil, nil}, {26..27, 27, nil, nil}}}}}>" = "#{inspect tree}"

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
