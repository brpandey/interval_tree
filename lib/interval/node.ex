defmodule Interval.Node do
  @moduledoc """
  Node serves as the building block for the interval tree

  Tracks the max interval high value for the subtree
  rooted at this node

  Stores interval in data field as well as left and right children
  """

  alias Interval.Node

  defstruct max: -1, # max interval finish value given the subtree rooted at this node
  data: nil,  # interval low, interval high
  left: nil, 
  right: nil

  
  @doc "Provides dump of node info to be used in Inspect protocol implementation"
  def info(%Node{} = node) do {node.data, node.max, node.left, node.right} end
  
  
  # Allows users to inspect this module type in a controlled manner
  defimpl Inspect do
    import Inspect.Algebra
    
    def inspect(t, opts) do
      info = Inspect.Tuple.inspect(Node.info(t), opts)
      concat ["", info, ""]
    end
  end
end
