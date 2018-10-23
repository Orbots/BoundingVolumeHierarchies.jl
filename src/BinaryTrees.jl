module BinaryTrees

export 
EmptyNode,
Node,
Branch,
BinaryTree,
DepthFirst,
left,
right,
data


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

function Base.iterate(iter::DepthFirst{T}, children::Vector{Node{T}}) where T
  if length(children) == 0
    return nothing
  end
  child = first(children)
  (data(child), vcat(Vector{Node{T}}(filter(x->x!=nothing,[left(child), right(child)])), rest(children)))
end

function Base.iterate(iter::DepthFirst{T}) where T
  (data(iter.tree),Vector{Node{T}}(filter(x->x!=nothing,[left(iter.tree), right(iter.tree)])))
end

Base.length(iter::DepthFirst{T}) where T = reduce( (acc,_)->acc+1, iter; init=0)

Base.iterate(tree::Node{T}) where T = iterate(DepthFirst(tree))
Base.iterate(iter::Node{T}, children::Vector{Node{T}}) where T = iterate(DepthFirst(iter), children)
Base.length(iter::Node{T}) where T = length(DepthFirst{T})

struct BreadthFirst{T}
  tree::BinaryTree{T}
end

function Base.iterate(iter::BreadthFirst{T}, children::Vector{Node{T}}) where T
  if length(children) == 0
    return nothing
  end
  child = last(children)
  (data(child), vcat(Vector{Node{T}}(filter(x->x!=nothing,[right(child), left(child)])), children[1:end-1]))
end

function Base.iterate(iter::BreadthFirst{T}) where T
 (data(iter.tree),Vector{Node{T}}(filter(x->x!=nothing,[right(iter.tree), left(iter.tree)])))
end

Base.length(iter::BreadthFirst{T}) where T = length(DepthFirst(iter.tree))

end
