using Test
using BinaryTrees
using AxisAlignedBoundingBoxes
using AxisAlignedBoundingBoxes: Vector3

using Base.Iterators

@testset "traverse" begin
  t = Node(1, Node(-2, Node(-3),Node(3,Node(-4),nothing)), Node(2,nothing,Node(4)))
  @test length(t) == 7
  @test [i for i in t] == [1,-2,-3,3,-4,2,4]
  @test [i for i in t] == reduce(vcat,DepthFirst(t))
  @test drop(DepthFirst(t),2) |> first == -3 
  @test drop(BreadthFirst(t),2) |> first == 2 
  @test reduce(vcat,BreadthFirst(t)) == [1, -2, 2, -3, 3, 4, -4]
  @test search(iseven,t) == -2
end


@testset "AABB" begin
  a = Vector3(1.0,1,1)
  o = Vector3(0.0,0,0)
  @test overlaps(AABB(o,a),AABB(0.5*a,2.0*a)) == true
  @test overlaps(AABB(o,a),AABB(10.0*a,20.0*a)) == false
  @test volume(AABB(o,a)) == 1.0
  @test volume(inflate(AABB(o,a),1.0)) == 3.0^3 
  @test contains(AABB(o,a),AABB(a*0.5,a*0.75)) == true
  @test contains(AABB(o,a),AABB(a,2.0*a)) == false
  @test contains(AABB(o,a),AABB(o,a)) == true
end
