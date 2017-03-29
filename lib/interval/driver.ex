defmodule Driver do

  alias Interval.Tree

  def run do
    clr_run()
  end

  def run({start, finish} = key)
  when is_integer(start) and is_integer(finish) and start <= finish do
    clr_run(key)
  end


  def clr_run(key \\ {19,20}) when is_tuple(key) do
    ## Create interval tree shown in above figure
    
    intervals = [{16, 21}, {8, 9}, {15, 23}, {25, 30}, {17, 19}, {5,8}, {6,10}, {0,3}, {26, 27}, {19, 20}]
    
    tree = create_tree(intervals)

    print_tree(tree)
    
    search_tree(tree, Interval.new(key))
  end


  def geeks_run(key \\ {16,25}) when is_tuple(key) do
    ## Create interval tree shown in above figure
    
    intervals = [{15, 20}, {10, 30}, {17, 19}, {5, 20}, {12, 15}, {30, 40}]
    
    tree = create_tree(intervals)

    print_tree(tree)

    search_tree(tree, Interval.new(key))
  end


  ##############################################################################
  # Helpers


  defp create_tree(intervals)
  when is_list(intervals) and is_tuple(hd(intervals)) do

    Enum.reduce(intervals, Tree.new, fn {start, finish}, tree_acc ->
      Tree.insert(tree_acc, Interval.new({start, finish}))
    end)
  end


  defp print_tree(%Tree{} = tree) do

    IO.puts "Interval tree dump and inorder traversal:\n"
    IO.puts "#{inspect tree}\n"

    list = Tree.traverse(tree)

    Enum.map(list, fn i -> IO.puts "#{i}" end)

    IO.puts ""

    :ok
  end


  defp search_tree(%Tree{} = tree, %Interval{} = key) do

    IO.puts("Searching for interval #{inspect key}")

    results = Tree.search(tree, key)
    
    IO.puts "Overlap search returns #{inspect results}"

    :ok
  end

  
end
