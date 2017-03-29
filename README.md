### Interval Tree

Implements an interval tree using an augmented binary search tree with an interval as the data field
and a max value tracking the highest interval high value in the subtree rooted at that node


Inspecting the interval tree structure shows a functional looking data structure
The first term in the tuple is the interval e.g. 16..21, the second is the max value e.g. 30, 
and the second and three are nexted tuples which comprise the left and right subtrees respectively..

#IntervalTree<{10, {16..21, 30, {8..9, 23, {5..8, 10, {0..3, 3, nil, nil}, {6..10, 10, nil, nil}}, {15..23, 23, nil, nil}}, {25..30, 30, {17..19, 20, nil, {19..20, 20, nil, nil}}, {26..27, 27, nil, nil}}}}>


Size 10

The interval tree dump is loosely translated
to this tree arrangment

                                               root:   {16..21, 30, 
                       l: {8..9, 23,                                          r: {25..30, 30, 
           l: {5..8, 10,           r: {15..23, 23, nil, nil}},  l: {17..19, 20, nil,          r: {26..27, 27, nil, nil}}}
                                                                      r: {19..20, 20, nil, nil}}
l: {0..3, 3, nil, nil}, r: {6..10, 10, nil, nil}}



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