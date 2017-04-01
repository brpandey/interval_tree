Interval Tree using a self-balancing AVL
========================================

* Implements an interval tree using an augmented self-balancing AVL tree with an interval 
  as the data field and a max value tracking the interval high value in the subtree 
  rooted at that node

* Inspecting the interval tree structure shows a functional looking data structure

* The first term is the tree size e.g 10.  The next is the root node.  The first term in 
  the root tuple is the interval e.g. 15..23, the second is the max value e.g. 30, 
  and the third and fourth are nested tuples which comprise the left and right 
  subtrees respectively.

* Operations
  * traverse - O(n)
  * insert - O(log n) where n is the number of nodes in the tree at insertion time
  * search - O(min(n, k log n)) where k is the number of overlapping intervals


## Tree Output

```elixir

IntervalTree<{10, {15..23, 30, {6..10, 10, {5..8, 8, {0..3, 3, nil, nil}, nil}, 
{8..9, 9, nil, nil}}, {17..19, 30, {16..21, 21, nil, nil}, {25..30, 30, 
{19..20, 20, nil, nil}, {26..27, 27, nil, nil}}}}}>

```

The interval tree dump is translated to this tree arrangment:

```elixir
                                      {15..23, 30}
                                  /                  \
                      {6..10, 10}                        {17..19, 30}
                      /        \                         /          \
                     /          \                       /            \
              {5..8, 8}        {8..9, 9}       {16..21, 21}     {25..30, 30}
              /                                                 /         \
             /                                                 /           \
      {0..3, 3}                                      {19..20, 20}         {26..27, 27}
```

### Example Run 1

```

$ iex -S mix
iex(1)> Driver.run 

...

Searching for interval
20..26

Here's the inorder traversal output

0..3
5..8
6..10
8..9
15..23 *
16..21 *
17..19
19..20 
25..30 *
26..27

Overlap search returns #MapSet<[16..21, 15..23, 25..30]>
```

### Example Run 2

```elixir

iex(2)> Driver.run({5,6}) 

...

0..3
5..8
6..10
8..9
15..23
16..21
17..19
19..20
25..30
26..27

Searching for interval 5..6
Overlap search returns #MapSet<[5..8]>
```

### Example Run 3

```elixir

iex(3)> tree = Driver.create_tree([{3,4}, {2,10}, {2, 24}])
IntervalTree<{3, {2..24, 24, {2..10, 10, nil, nil}, {3..4, 4, nil, nil}}}>

iex(4)> Driver.print_tree(tree)
Interval tree dump and inorder traversal:

#IntervalTree<{3, {2..24, 24, {2..10, 10, nil, nil}, {3..4, 4, nil, nil}}}>

2..10
2..24
3..4

:ok

iex(5)> Driver.search_tree(tree, Interval.new({10, 20}))
Searching for interval 10..20
Overlap search returns #MapSet<[2..24]>
:ok

```


## NOTES


It was interesting to see how the one dimensional check overlap problem
is transformed into a 2-d tree problem

Here are the relevant code bits that pertain to this from lib/tree.ex

```elixir

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


```

AVL trees rock! Especially in Elixir :heart_eyes:

## Thanks!

Thanks to geeksforgeeks.org and the CLR algorithms textbook 
for Interval and AVL Tree descriptions and implementations

* http://www.geeksforgeeks.org/interval-tree/
* http://www.geeksforgeeks.org/avl-tree-set-1-insertion/
* https://en.wikipedia.org/wiki/Interval_tree#Augmented_tree

Bibek Pandey