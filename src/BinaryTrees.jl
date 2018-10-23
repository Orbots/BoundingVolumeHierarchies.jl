"""
Binary Search Tree
"""
module BinaryTrees

export 
EmptyNode,
Node,
Branch,
BinaryTree,
DepthFirst,
BreadthFirst,
BinarySearch,
empty_node,
left,
right,
data,
insert,
search


abstract type BinaryTree{T} end
const EmptyNode = Nothing
const empty_node = nothing

const Branch{T} = Union{BinaryTree{T},EmptyNode}

left(tree::EmptyNode) where T = nothing
right(tree::EmptyNode) where T = nothing
data(tree::EmptyNode) where T = nothing

struct Node{T} <: BinaryTree{T}
  data::T
  left::Branch{T}
  right::Branch{T}
end

Node(data::T) where T = Node(data,empty_node,empty_node)

left(tree::Node{T}) where T = tree.left
right(tree::Node{T}) where T = tree.right
data(tree::Node{T}) where T = tree.data
leaf(data::T) where T = Node(data)


struct DepthFirst{T}
  tree::BinaryTree{T}
end

rest(a::Vector{T}) where T = Vector{T}(a[2:end])

#==== DepthFirst Traversal ===#
function Base.iterate(iter::DepthFirst{T}, children::Vector{Node{T}}) where T
  if length(children) == 0
    return nothing
  end
  child = first(children)
  (child, vcat(Vector{Node{T}}(filter(x->x!=nothing,[left(child), right(child)])), rest(children)))
end

function Base.iterate(iter::DepthFirst{T}) where T
  (iter.tree,Vector{Node{T}}(filter(x->x!=nothing,[left(iter.tree), right(iter.tree)])))
end

Base.length(iter::DepthFirst{T}) where T = reduce( (acc,_)->acc+1, iter; init=0)

Base.iterate(tree::Node{T}) where T = iterate(DepthFirst(tree))
Base.iterate(iter::Node{T}, children::Vector{Node{T}}) where T = iterate(DepthFirst(iter), children)
Base.length(iter::Node{T}) where T = length(DepthFirst{T}(iter))

#===== BreadthFirst Traversal ===#
struct BreadthFirst{T}
  tree::BinaryTree{T}
end

function Base.iterate(iter::BreadthFirst{T}, children::Vector{Node{T}}) where T
  if length(children) == 0
    return nothing
  end
  child = last(children)
  (child, vcat(Vector{Node{T}}(filter(x->x!=nothing,[right(child), left(child)])), children[1:end-1]))
end

function Base.iterate(iter::BreadthFirst{T}) where T
 (iter.tree,Vector{Node{T}}(filter(x->x!=nothing,[right(iter.tree), left(iter.tree)])))
end

Base.length(iter::BreadthFirst{T}) where T = length(DepthFirst(iter.tree))

#===== BinarySearch Traversal ===#
struct BinarySearch{T}
  tree::BinaryTree{T}
  comparison::Function
end

BinarySearch(tree::BinaryTree{T}, data::T) where {T} = BinarySearch{T}(tree, x->data < x)

function Base.iterate(iter::BinarySearch{T}, subtree::Union{Node{T}, EmptyNode}) where T
  if subtree == empty_node 
    return nothing
  end

  if iter.comparison(data(subtree))
    ((subtree,:left), left(subtree))
  else
    ((subtree,:right), right(subtree))
  end
end

function Base.iterate(iter::BinarySearch{T}) where T
  iterate(iter, iter.tree)
end

Base.length(iter::BinarySearch{T}) where T = reduce( (acc,_)->acc+1, iter; init=0)

"""
  search nodes until ftest passes 
"""
search( ftest::Function, tree::Node{T} ) where T = Iterators.filter(ftest,tree) |> first

"""
  return a new tree with new node inserted on branch where data < parent.data
"""
insert( t::BinaryTree{T}, d::T ) where T = 
  reduce( (n,(sn,direction))->
             direction == :left ? Node(data(sn),n,right(sn)) :
                                  Node(data(sn),left(sn),n), 
           Iterators.reverse(BinarySearch(t,d)|>collect) ; 
           init=Node(d,empty_node,empty_node))

insert( d::T ) where T = Node(d,empty_node,empty_node)

end
