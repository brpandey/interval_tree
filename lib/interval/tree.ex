defmodule Interval.Tree do
  @moduledoc """
  Module stores interval data in a tree structure called an interval tree

  The underlying tree implements a self-balancing AVL tree ensuring
  all insert operations are O(log n) and that tree height is always O(log n)

  The tree node contains the interval data which 
  contains the start and finish times

  We also keep track of the max time for that node's subtree.  This
  is helpful when we compute the overlap search

  The left and right child nodes of the current node are stored in the 
  left and right fields respectively

  Thanks to geeksforgeeks.org and the CLR algorithms textbook 
  for Interval and AVL Tree descriptions and implementations

  http://www.geeksforgeeks.org/interval-tree/
  http://www.geeksforgeeks.org/avl-tree-set-1-insertion/
  https://en.wikipedia.org/wiki/Interval_tree#Augmented_tree


  Implemented operations are traverse, search, and insert
  """

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
    list = List.flatten(["#{inspect(interval)}"], list)

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
    do_search(node, key, MapSet.new())
  end

  # Private helper functions which assist in the recursion

  # search base case matching nil node
  def do_search(nil, %Interval{}, acc), do: acc

  def do_search(
        %Node{data: %Interval{} = t1, left: t1_left, right: t1_right},
        %Interval{} = t2,
        acc
      ) do
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

    acc =
      cond do
        t1_left != nil and t1_left.max > t2.start ->
          do_search(t1_left, t2, acc)

        true ->
          acc
      end

    # If we have an "overlap" with the current node's start and the right's
    # aggregate max finish, then search the right subtree
    # (notice this pretty well resembles the classic overlap condition with the 
    #  difference being the aggregate max term)

    acc =
      cond do
        t1_right != nil and t1.start < t2.finish and t1_right.max > t2.start ->
          do_search(t1_right, t2, acc)

        true ->
          acc
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
    node = do_insert(node, value)

    # Update the passed back tree with the updated size
    %Tree{tree | root: node, size: tree.size + 1}
  end

  # Private helper functions which assist in the recursion

  # Base Case - empty tree - pattern match on empty node
  defp do_insert(nil, %Interval{} = interval) do
    %Node{data: interval, max: interval.finish, height: 1}
  end

  # Non-empty, traverse to left
  defp do_insert(
         %Node{data: %Interval{start: low}, left: l, right: r} = n,
         %Interval{start: start_key} = interval
       )
       when start_key < low do
    # Perform normal BST insertion
    l = do_insert(l, interval)

    # update the node with the updated left child,
    # also update height and max interval
    n =
      %Node{n | left: l, height: max_height(l, r) + 1}
      |> update_max_interval

    # ensure balance is maintained
    _node = balance(n, start_key)
  end

  # Non-empty, traverse to right
  defp do_insert(
         %Node{data: %Interval{start: low}, left: l, right: r} = n,
         %Interval{start: start_key} = interval
       )
       when start_key >= low do
    # recurse with right subtree
    r = do_insert(r, interval)

    # update the node with updated right child, 
    # also update height and max interval
    n =
      %Node{n | right: r, height: max_height(l, r) + 1}
      |> update_max_interval

    # ensure balance is maintained
    _node = balance(n, start_key)
  end

  ##############################################################################
  # AVL balance and rotation helpers

  defp balance(%Node{left: l, right: r} = node, low_key)
       when is_integer(low_key) do
    # Using height delta we determine
    # if we need to balance the tree at this node
    delta = height_delta(node)

    # 4 cases to handle a node imbalance

    _node =
      cond do
        # Case 1, Left Left

        # Since the delta is greater than 1, the left subtree is higher
        # and since low_key is less than y's start_key it was inserted on its left
        # Hence - left left

        #         z                                      y 
        #        / \                                   /   \
        #       y   T4      Right Rotate (z)          x      z
        #      / \          - - - - - - - - ->      /  \    /  \ 
        #     x   T3                               T1  T2  T3  T4
        #    / \
        #  T1   T2

        delta > 1 and l != nil and l.data != nil and low_key < l.data.start ->
          right_rotate(node)

        # Case 2, Right Right

        # Since the delta is less than -1, the right subtree is higher
        # and since the low_key is greater than y's start_key it was inserted on the right
        # Hence - right right

        #    z                                y
        #   /  \                            /   \ 
        #  T1   y     Left Rotate(z)       z      x
        #      /  \   - - - - - - - ->    / \    / \
        #     T2   x                     T1  T2 T3  T4
        #         / \
        #       T3  T4

        delta < -1 and r != nil and r.data != nil and low_key >= r.data.start ->
          left_rotate(node)

        # Case 3, Left Right

        # Since the delta is greater than 1, the left subtree is higher
        # Since the low_key is greater than in this case y's start key, the node
        # was inserted on y's right subtree
        # Hence - left right

        #      z                               z                           x
        #     / \                            /   \                        /  \ 
        #    y   T4  Left Rotate (y)        x    T4  Right Rotate(z)    y      z
        #   / \      - - - - - - - - ->    /  \      - - - - - - - ->  / \    / \
        # T1   x                          y    T3                    T1  T2 T3  T4
        #     / \                        / \
        #   T2   T3                    T1   T2

        delta > 1 and l != nil and l.data != nil and low_key >= l.data.start ->
          %Node{node | left: left_rotate(l)} |> right_rotate

        # Case 4, Right Left

        # Since the delta is less than -1, the right subtree is higher
        # Since the low_key is less than y's start key, the node
        # was inserted on y's left subtree
        # Hence - right left

        #    z                            z                            x
        #   / \                          / \                          /  \ 
        # T1   y   Right Rotate (y)    T1   x      Left Rotate(z)   z      y
        #     / \  - - - - - - - - ->     /  \   - - - - - - - ->  / \    / \
        #    x   T4                      T2   y                  T1  T2  T3  T4
        #   / \                              /  \
        # T2   T3                           T3   T4

        delta < -1 and r != nil and r.data != nil and low_key < r.data.start ->
          %Node{node | right: right_rotate(r)} |> left_rotate

        # Default case
        true ->
          node
      end
  end

  _ = """
  Right rotate subtree rooted at z. See following diagram
  We rotate z (the old root) to the right leaving y as the new root

  T1, T2, T3 and T4 are subtrees.

         z                                      y 
        / \                                   /   \
       y   T4      Right Rotate (z)          x      z
      / \          - - - - - - - - ->      /  \    /  \ 
     x   T3                               T1  T2  T3  T4
    / \
  T1   T2

  """

  defp right_rotate(%Node{left: %Node{left: x, right: t3} = y, right: t4} = z) do
    # Perform rotation, update heights and max interval
    z =
      %Node{z | left: t3, height: max_height(t3, t4) + 1}
      |> update_max_interval

    _y =
      %Node{y | right: z, height: max_height(x, z) + 1}
      |> update_max_interval
  end

  _ = """
  Left rotate subtree rooted at z. See following diagram
  We rotate z (the old root) to the left leaving y as the new root


    z                                y
   /  \                            /   \ 
  T1   y     Left Rotate(z)       z      x
      /  \   - - - - - - - ->    / \    / \
     T2   x                     T1  T2 T3  T4
         / \
       T3  T4

  """

  defp left_rotate(%Node{left: t1, right: %Node{left: t2, right: x} = y} = z) do
    # Perform rotation, update heights and max interval
    z =
      %Node{z | right: t2, height: max_height(t1, t2) + 1}
      |> update_max_interval

    _y =
      %Node{y | left: z, height: max_height(z, x) + 1}
      |> update_max_interval
  end

  ##############################################################################
  # Max interval flag helpers

  # Update max interval
  defp update_max_interval(%Node{data: interval, left: left, right: right} = node) do
    max = Kernel.max(do_max(left), do_max(right)) |> Kernel.max(interval.finish)
    Kernel.put_in(node.max, max)
  end

  defp do_max(nil), do: 0
  defp do_max(%Node{max: max}), do: max

  ##############################################################################
  # Height helpers

  # Update max tree height
  defp max_height(left, right) do
    Kernel.max(do_height(left), do_height(right))
  end

  defp height_delta(nil), do: 0
  defp height_delta(%Node{left: l, right: r}), do: do_height(l) - do_height(r)

  defp do_height(nil), do: 0
  defp do_height(%Node{height: height}), do: height

  @doc "Provides dump of tree info to be used in Inspect protocol implementation"
  def info(%Tree{} = tree) do
    {tree.size, tree.root}
  end

  ##############################################################################
  # Inspect Protocol implementation -- custom behavior when inspect is invoked

  # Allows users to inspect this module type in a controlled manner
  defimpl Inspect do
    import Inspect.Algebra

    def inspect(t, opts) do
      info = Inspect.Tuple.inspect(Tree.info(t), opts)
      concat(["#IntervalTree<", info, ">"])
    end
  end
end
