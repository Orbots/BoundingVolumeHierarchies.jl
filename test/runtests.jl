using Test
using BinaryTrees
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

