defmodule Interval.Node do
  @moduledoc """
  Node serves as the building block for the interval tree

  Tracks the max interval high value for the subtree
  rooted at this node

  Stores interval in data field.  Stores left and right children as well.

  We keep track of the height of subtrees for AVL balancing

  Not too much different than the C counterpart
  (https://bitbucket.org/brpandey/c-data-structures/src)

  struct Node {
    int max;
    int height;
    struct Interval data;
    struct Node* left;
    struct Node* right;
  };

  """

  alias Interval.Node

  # max interval finish value given the subtree rooted at this node
  defstruct max: -1,
            # height value
            height: -1,
            # interval low, interval high
            data: nil,
            left: nil,
            right: nil

  @doc "Provides dump of node info to be used in Inspect protocol implementation"
  def info(%Node{} = node) do
    {node.data, node.max, node.left, node.right}
  end

  # Allows users to inspect this module type in a controlled manner
  defimpl Inspect do
    import Inspect.Algebra

    def inspect(t, opts) do
      info = Inspect.Tuple.inspect(Node.info(t), opts)
      concat(["", info, ""])
    end
  end
end
