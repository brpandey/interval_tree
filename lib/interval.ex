defmodule Interval do

  defstruct start: -1, finish: -1


  @doc "Create new interval given start time and finish"
  def new({start, finish})
  when is_integer(start) and is_integer(finish) and start <= finish do
    %Interval{start: start, finish: finish}
  end


  def overlap?(%Interval{} = t1, %Interval{} = t2) do
    
    # This handles these cases
    
    # 1)
    #     X------Y
    #         A-----B
    # 2)
    #         X------Y
    #     A-----B
    # 3)
    #        A-----B
    #     X------------Y
    # 4)
    #     X-----------Y
    #        A-----B
    #
    # 5) and non-overlapping case
    #     X------Y            M-----N
    #               A-----B
    
    # Periods that just touch each other e.g. t1.finish = 2:00
    # and t2.start = 2:00 are not considered overlapping
    
    # Thus we don't use <= but instead < or conversely, >= but instead >
    
    cond do
      (t1.start < t2.finish and t1.finish > t2.start) -> true
      true -> false 
    end    
  end



  @spec info(struct) :: Range.t
  def info(%Interval{} = round) do round.start..round.finish end


  # Allows users to inspect this module type in a controlled manner
  defimpl Inspect do
    import Inspect.Algebra

    def inspect(t, opts) do
      info = Inspect.Range.inspect(Interval.info(t), opts)
      concat ["", info, ""]
    end
  end


end
