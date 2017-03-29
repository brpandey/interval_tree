defmodule Interval.Tree do
  @moduledoc """
  Module stores interval data in a tree structure called an interval tree

  The tree node contains the interval data which 
  contains the start and finish times

  We also keep track of the max time for that node's subtree.  This
  is helpful when we compute the overlap search
  
  The left and right child nodes of the current node are stored in the 
  left and right fields respectively

  Thanks to geeksforgeeks.org and the CLR algorithms textbook 
  for Interval Tree descriptions and implementations

  http://www.geeksforgeeks.org/interval-tree/
  https://en.wikipedia.org/wiki/Interval_tree#Augmented_tree


  Implemented operations are traverse, search, and insert
  """


  # TODO: Tree should really be self-balancing tree like AVL or Red-Black instead of BST


  alias Interval.Tree, as: Tree
  alias Interval.Node, as: Node


  # Define interval tree struct
  defstruct size: 0, root: nil



  def new, do: %Tree{}


  ##############################################################################
  # Traverse - O(n)


  @doc "Traverse implements an inorder traversal"
  def traverse(%Tree{root: node}) do
    list = do_traverse(node, [])

    # Since we prepended to the list for O(1), 
    # we now need to reverse to ensure correct order
    Enum.reverse(list)
  end

  # Private helper functions which assist in the recursion

  # Matches case where node is nil
  defp do_traverse(nil, list), do: list

  # Matches case where node is non-empty
  defp do_traverse(%Node{data: interval, left: left, right: right}, list)
  when is_list(list) do

    # Recurse left
    list = do_traverse(left, list)

    # Print current interval node
    list = List.flatten(["#{inspect interval}"], list)

    # Recurse right
    _list = do_traverse(right, list)
  end


  ##############################################################################
  # Search - O(min(n, k log n)) where k is the number of overlapping intervals


  @doc """
  Search whether a given interval key overlaps
  with any interval nodes, returns ALL overlaps
  """

  def search(%Tree{root: node}, %Interval{} = key) do
    do_search(node, key, MapSet.new)
  end

  # Private helper functions which assist in the recursion

  # search base case matching nil node
  def do_search(nil, %Interval{}, acc), do: acc

  def do_search(%Node{data: %Interval{} = t1, left: t1_left, right: t1_right},
                %Interval{} = t2, acc) do
    
    # check if given interval key overlaps with current interval node
    acc =
      case Interval.overlap?(t1, t2) do
        true -> MapSet.put(acc, t1)
        false -> acc
      end
    
    # recurse left and right

    # NOTE: the classic overlap condition is  
    # (t1.start < t2.finish and t1.finish > t2.start)


    # Given that the left child exists and its max is greater than
    # the interval key's start, then the key may overlap with an interval 
    # node in the left subtree, search left! 
    # (notice this is half the classic overlap condition)

    acc = cond do
      t1_left != nil and t1_left.max > t2.start ->
        do_search(t1_left, t2, acc)
      true -> acc
    end
    
    
    # If we have an "overlap" with the current node's start and the right's
    # aggregate max finish, then search the right subtree
    # (notice this pretty well resembles the classic overlap condition with the 
    #  difference being the aggregate max term)

    acc = cond do
      t1_right != nil and t1.start < t2.finish and t1_right.max > t2.start ->
        do_search(t1_right, t2, acc)
      true -> acc
    end
    
    acc
  end


  ##############################################################################
  # Insert - O(log n)

  @doc """
  Public insert method, inserts interval value into the interval key using
  the low interval node value to maintain sorted order
  """

  def insert(%Tree{root: node} = tree, %Interval{} = value) do
    {node, _max} = do_insert(node, value)
    
    # Update the passed back tree with the updated size
    %Tree{tree | root: node, size: tree.size + 1}
  end

  # Private helper functions which assist in the recursion
  
  # Base Case - empty tree - pattern match on empty node
  defp do_insert(nil, %Interval{} = interval) do
    node = %Node{data: interval, max: interval.finish}
    {node, node.max}
  end


  # Non-empty, traverse to left
  defp do_insert(%Node{data: %Interval{start: low}, left: left} = node, 
                 %Interval{start: start_key} = interval)
  when start_key < low do
    
    {left, max} = do_insert(left, interval)

    # If the subtree has a higher max value, store that as the new max
    node = update_max(node, max)

    # update the left child
    node = %Node{node | left: left}

    {node, node.max}
  end
  
  
  # Non-empty, traverse to right
  defp do_insert(%Node{data: %Interval{start: low}, right: right} = node, 
                 %Interval{start: start_key} = interval)
  when start_key >= low do
    
    # recurse with right subtree
    {right, max} = do_insert(right, interval)

    # If the subtree has a higher max value, store that as the new max
    node = update_max(node, max)

    # update the right child
    node = %Node{node | right: right}

    {node, node.max}
  end


  ##############################################################################
  # Helpers


  # Helper function to update max if needed - O(h) where h is tree height
  defp update_max(%Node{max: current} = node, max) do
    if(max > current) do Kernel.put_in(node.max, max) else node end
  end

    
  @doc "Provides dump of tree info to be used in Inspect protocol implementation"
  def info(%Tree{} = tree) do {tree.size, tree.root} end
  

  ##############################################################################
  # Inspect Protocol implementation -- custom behavior when inspect is invoked
  

  # Allows users to inspect this module type in a controlled manner
  defimpl Inspect do
    import Inspect.Algebra
    
    def inspect(t, opts) do
      info = Inspect.Tuple.inspect(Tree.info(t), opts)
      concat ["#IntervalTree<", info, ">"]
    end
  end


end



