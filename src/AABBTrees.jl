module AABBTrees
export
AABBNode,
AABBNodeData,
insert,
entity,
query

using BinaryTrees
import BinaryTrees.insert
using AxisAlignedBoundingBoxes
using AxisAlignedBoundingBoxes: Vector3
import AxisAlignedBoundingBoxes.AABB
import Base.isless
using Base.Iterators


#abstract type VolumetricEntity end

#AABB( entity::VolumetricEntity ) = AABB(zero(Vector3), zero(Vector3))

#struct AABBNodeData{T,S<:VolumetricEntity}
struct AABBNodeData{T,S}
  aabb::AABB{T}
  entity::S  #!me union of parent pointer and entityID?  entity only relevant at leaf
end


const AABBNode{T,S} = Node{AABBNodeData{T,S}}

entity(n::AABBNode{T,S}) where {T,S} = data(n).entity

# true means take left branch
function branch_compare( aabb::AABB{T}, n::AABBNode{T,S} ) where {T,S}
  if n.left == nothing || n.right == nothing ||
     volume(union(aabb,n.left.data.aabb)) < volume(union(aabb,n.right.data.aabb))
     true
   else
     false
  end
end

partial(f,x) = y->f(x,y)

function insert_child( direction::Symbol, anc::AABBNode{T,S}, child::AABBNode{T,S} ) where {T,S}
  larger_aabb = union(data(anc).aabb,data(child).aabb)
  direction == :left ? Node(AABBNodeData(larger_aabb,data(anc).entity), child, right(anc)) :
                       Node(AABBNodeData(larger_aabb,data(anc).entity), left(anc), child)
end

function insert( t::AABBNode{T,S}, d::AABBNodeData{T,S} ) where {T,S}
  aabb = d.aabb
  path = BinarySearch(t, partial(branch_compare,aabb))
  rpath = Iterators.reverse(path|>collect)

  # no entities are stored on branches, so create new Branch with existing Leaf left and new Leaf right
  rleaf = (take(rpath,1) |> first)[1]
  rpath = drop(rpath,1)
  twigaabb = union(aabb,data(rleaf).aabb)
  newleaf = Node(d,empty_node,empty_node)
  twig = Node(AABBNodeData(twigaabb, zero(S)),newleaf,rleaf) 

  reduce((n,(sn,direction))->
           insert_child( direction, sn, n ),
         rpath ; 
         init=twig)
end

insert( t::AABBNode{T,S}, aabb::AABB{T}, entity::S ) where {T,S} = insert( t, AABBNodeData(aabb, entity) )

query( t::AABBNode{T,S}, qaabb::AABB{T} ) where {T,S} = entity.(Leaves(t,n->overlaps(data(n).aabb, qaabb ))) 

end
