module AxisAlignedBoundingBoxes
const AABBs = AxisAlignedBoundingBoxes

export
AABB,
createAABB,
overlaps,
contains,
inflate,
volume


using StaticArrays
using Base.Iterators
using LinearAlgebra
import Base.union
import Base.isless

const Point{T}=SVector{3,T}
const Vector3=Point
const Matrix3{T}=SMatrix{3,3,T,9}


struct AABB{T}
  min::Vector3{T}
  max::Vector3{T}
end

function AABB( minx::T, maxx::T, miny::T, maxy::T, minz::T, maxz::T ) where {T}
  AABB(Vector3([minx, miny, minz]), Vector3([maxx, maxy, maxz]))
end

"""
make an AABB out of a triangle ( 3 points )
"""
function createAABB( a::Vector3{T}, b::Vector3{T}, c::Vector3{T} ) where {T} 
  @inbounds r = AABB(min(a[1],b[1],c[1]), max(a[1],b[1],c[1]), 
                     min(a[2],b[2],c[2]), max(a[2],b[2],c[2]), 
                     min(a[3],b[3],c[3]), max(a[3],b[3],c[3])); r
end

function createAABB( a::Vector3{T}, b::Vector3{T}, c::Vector3{T}, rest::Vector3{T}...) where {T} 
  @inbounds r = AABB(min(a[1],b[1],c[1],map(p->p[1],rest)...), max(a[1],b[1],c[1],map(p->p[1],rest)...), 
                     min(a[2],b[2],c[2],map(p->p[2],rest)...), max(a[2],b[2],c[2],map(p->p[2],rest)...), 
                     min(a[3],b[3],c[3],map(p->p[3],rest)...), max(a[3],b[3],c[3],map(p->p[3],rest)...)); r
end


function AABB( trii::Int64, P::Vector{T}, tris::Vector{Int64} ) where {T} 
  trii = (trii-1)*3
  @inbounds r = createAABB( P[tris[trii+1]], P[tris[trii+2]], P[tris[trii+3]] ); r
end

AABB( shapec::ST, ishape::IntT ) where {IntT<:Integer,ST} = createAABB( points(shapec, ishape)... )
AABB( ishape::IntT, shapec::ST ) where {IntT<:Integer,ST} = AABB(shapec, ishape)

"""
make an AABB for an edge
"""
function createAABB( a::Vector3{T}, b::Vector3{T} ) where {T} 
  @inbounds r = AABB(min(a[1],b[1]), max(a[1],b[1]), 
                     min(a[2],b[2]), max(a[2],b[2]), 
                     min(a[3],b[3]), max(a[3],b[3])); r
end
"""
"""
function union( a::AABB{T}, b::AABB{T} ) where {T}
  @inbounds @fastmath r = AABB(min(a.min[1],b.min[1]), max(a.max[1],b.max[1]), 
                               min(a.min[2],b.min[2]), max(a.max[2],b.max[2]), 
                               min(a.min[3],b.min[3]), max(a.max[3],b.max[3])); r
end

"""
check if all extents of a are < all extents of b.  if so, then disjoint. 
"""
function isless(a::AABB{T}, b::AABB{T}) where {T}
  @inbounds @fastmath r = (a.max[1] < b.min[1]) || (a.max[2] < b.min[2]) || (a.max[3] < b.min[3]); r
end


function overlaps(a::AABB{T}, b::AABB{T}) where {T}
  @inbounds @fastmath r = !((a < b) || (b < a)); r
end


function contains(a::AABB{T}, b::AABB{T}) where {T}
  @inbounds @fastmath r = ((a.max[1] >= b.max[1]) && (a.min[1] <= b.min[1])) && 
  ((a.max[2] >= b.max[2]) && (a.min[2] <= b.min[2])) && 
  ((a.max[3] >= b.max[3]) && (a.min[3] <= b.min[3])); r  
end


function inflate(a::AABB{T}, r::S) where {T,S}
  @inbounds @fastmath rv = Vector3([r,r,r])
  @inbounds @fastmath r = AABB( a.min-rv, a.max+rv ); r
end


function volume(a::AABB{T}) where {T}
  @inbounds @fastmath r = (a.max[1]-a.min[1])*(a.max[2]-a.min[2])*(a.max[3]-a.min[3]); r
end

end
