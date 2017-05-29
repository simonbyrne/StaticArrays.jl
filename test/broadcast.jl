# issue 191
@testset "Broadcast sizes" begin
    @test broadcast_sizes(1, 1, 1) === (Size(), Size(), Size())
    for t in (SVector{2}, MVector{2}, SMatrix{2, 2}, MMatrix{2, 2})
        @test broadcast_sizes(ones(t), ones(t), ones(t)) === (Size(t), Size(t), Size(t))
        @test broadcast_sizes(ones(t), 1, ones(t)) === (Size(t), Size(), Size(t))
        @test broadcast_sizes(1, ones(t), ones(t)) === (Size(), Size(t), Size(t))
        @test broadcast_sizes(ones(t), ones(t), 1) === (Size(t), Size(t), Size())
        @test broadcast_sizes(1, ones(t), 1) === (Size(), Size(t), Size())
        @test broadcast_sizes(ones(t), 1, 1) === (Size(t), Size(), Size())
        @test broadcast_sizes(1, 1, ones(t)) === (Size(), Size(), Size(t))
    end
    @test broadcast((a,b,c)->0, SVector(1,1), 0, 0) == SVector(0, 0)
end

@testset "Broadcast" begin
    @testset "2x2 StaticMatrix with StaticVector" begin
        m = @SMatrix [1 2; 3 4]
        v = SVector(1, 4)
        @test @inferred(broadcast(+, m, v)) === @SMatrix [2 3; 7 8]
        @test @inferred(m .+ v) === @SMatrix [2 3; 7 8]
        @test @inferred(v .+ m) === @SMatrix [2 3; 7 8]
        @test @inferred(m .* v) === @SMatrix [1 2; 12 16]
        @test @inferred(v .* m) === @SMatrix [1 2; 12 16]
        @test @inferred(m ./ v) === @SMatrix [1 2; 3/4 1]
        @test @inferred(v ./ m) === @SMatrix [1 1/2; 4/3 1]
        @test @inferred(m .- v) === @SMatrix [0 1; -1 0]
        @test @inferred(v .- m) === @SMatrix [0 -1; 1 0]
        @test @inferred(m .^ v) === @SMatrix [1 2; 81 256]
        @test @inferred(v .^ m) === @SMatrix [1 1; 64 256]
    end

    @testset "2x2 StaticMatrix with 1x2 StaticMatrix" begin
        m1 = @SMatrix [1 2; 3 4]
        m2 = @SMatrix [1 4]
        # @test @inferred(broadcast(+, m1, m2)) === @SMatrix [2 6; 4 8] #197
        # @test @inferred(m1 .+ m2) === @SMatrix [2 6; 4 8] #197
        @test @inferred(m2 .+ m1) === @SMatrix [2 6; 4 8]
        # @test @inferred(m1 .* m2) === @SMatrix [1 8; 3 16] #197
        @test @inferred(m2 .* m1) === @SMatrix [1 8; 3 16]
        # @test @inferred(m1 ./ m2) === @SMatrix [1 1/2; 3 1] #197
        @test @inferred(m2 ./ m1) === @SMatrix [1 2; 1/3 1]
        # @test @inferred(m1 .- m2) === @SMatrix [0 -2; 2 0] #197
        @test @inferred(m2 .- m1) === @SMatrix [0 2; -2 0]
        # @test @inferred(m1 .^ m2) === @SMatrix [1 16; 1 256] #197
    end

    @testset "1x2 StaticMatrix with StaticVector" begin
        m = @SMatrix [1 2]
        v = SVector(1, 4)
        @test @inferred(broadcast(+, m, v)) === @SMatrix [2 3; 5 6]
        @test @inferred(m .+ v) === @SMatrix [2 3; 5 6]
        # @test @inferred(v .+ m) === @SMatrix [2 3; 5 6] #197
        @test @inferred(m .* v) === @SMatrix [1 2; 4 8]
        # @test @inferred(v .* m) === @SMatrix [1 2; 4 8] #197
        @test @inferred(m ./ v) === @SMatrix [1 2; 1/4 1/2]
        # @test @inferred(v ./ m) === @SMatrix [1 1/2; 4 2] #197
        @test @inferred(m .- v) === @SMatrix [0 1; -3 -2]
        # @test @inferred(v .- m) === @SMatrix [0 -1; 3 2] #197
        @test @inferred(m .^ v) === @SMatrix [1 2; 1 16]
        # @test @inferred(v .^ m) === @SMatrix [1 1; 4 16] #197
    end

    @testset "StaticVector with StaticVector" begin
        v1 = SVector(1, 2)
        v2 = SVector(1, 4)
        @test @inferred(broadcast(+, v1, v2)) === SVector(2, 6)
        @test @inferred(v1 .+ v2) === SVector(2, 6)
        @test @inferred(v2 .+ v1) === SVector(2, 6)
        @test @inferred(v1 .* v2) === SVector(1, 8)
        @test @inferred(v2 .* v1) === SVector(1, 8)
        @test @inferred(v1 ./ v2) === SVector(1, 1/2)
        @test @inferred(v2 ./ v1) === SVector(1, 2/1)
        @test @inferred(v1 .- v2) === SVector(0, -2)
        @test @inferred(v2 .- v1) === SVector(0, 2)
        @test @inferred(v1 .^ v2) === SVector(1, 16)
        @test @inferred(v2 .^ v1) === SVector(1, 16)
        # test case issue #199
        @test @inferred(SVector(1) .+ SVector()) === SVector()
        # @test @inferred(SVector() .+ SVector(1)) === SVector()
        # test case issue #200
        # @test @inferred(v1 .+ v2') === @SMatrix [2 5; 3 5] # issue
    end

    @testset "StaticVector with Scalar" begin
        v = SVector(1, 2)
        @test @inferred(broadcast(+, v, 2)) === SVector(3, 4)
        @test @inferred(v .+ 2) === SVector(3, 4)
        @test @inferred(2 .+ v) === SVector(3, 4)
        @test @inferred(v .* 2) === SVector(2, 4)
        @test @inferred(2 .* v) === SVector(2, 4)
        @test @inferred(v ./ 2) === SVector(1/2, 1)
        @test @inferred(2 ./ v) === SVector(2, 1/1)
        @test @inferred(v .- 2) === SVector(-1, 0)
        @test @inferred(2 .- v) === SVector(1, 0)
        @test @inferred(v .^ 2) === SVector(1, 4)
        @test @inferred(2 .^ v) === SVector(2, 4)
    end

    @testset "Mutating broadcast!" begin
        # No setindex! error
        A = eye(SMatrix{2, 2}); @test_throws ErrorException broadcast!(+, A, A, SVector(1, 4))
        A = eye(MMatrix{2, 2}); @test @inferred(broadcast!(+, A, A, SVector(1, 4))) == @MMatrix [2 1; 4 5]
        A = eye(MMatrix{2, 2}); @test @inferred(broadcast!(+, A, A, @SMatrix([1  4]))) == @MMatrix [2 4; 1 5]
        A = @MMatrix([1 0]); @test_throws DimensionMismatch broadcast!(+, A, A, SVector(1, 4))
        A = @MMatrix([1 0]); @test @inferred(broadcast!(+, A, A, @SMatrix([1 4]))) == @MMatrix [2 4]
        A = @MMatrix([1 0]); @test @inferred(broadcast!(+, A, A, 2)) == @MMatrix [3 2]
    end

    @testset "f.(args...) syntax" begin
        x = SVector(1, 3.2, 4.7)
        y = SVector(3.5, pi, 1e-4)
        α = 0.2342
        @test sin.(x) === broadcast(sin, x)
        @test sin.(α) === broadcast(sin, α)
        @test sin.(3.2) === broadcast(sin, 3.2) == sin(3.2)
        @test factorial.(3) === broadcast(factorial, 3)
        @test atan2.(x, y) === broadcast(atan2, x, y)
        # test case issue #200
        # @test atan2.(x, y') === broadcast(atan2, x, y')
        @test atan2.(x, α) === broadcast(atan2, x, α)
        @test atan2.(α, y') === broadcast(atan2, α, y')
    end

    @testset "eltype after broadcast" begin
        # test cases issue #198
        # let a = SVector{4, Number}(2, 2.0, 4//2, 2+0im)
        #     @test eltype(a + 2) == Number
        #     @test eltype(a - 2) == Number
        #     @test eltype(a * 2) == Number
        #     @test eltype(a / 2) == Number
        # end
        # let a = SVector{3, Real}(2, 2.0, 4//2)
        #     @test eltype(a + 2) == Real
        #     @test eltype(a - 2) == Real
        #     @test eltype(a * 2) == Real
        #     @test eltype(a / 2) == Real
        # end
        # let a = SVector{3, Real}(2, 2.0, 4//2)
        #     @test eltype(a + 2.0) == Float64
        #     @test eltype(a - 2.0) == Float64
        #     @test eltype(a * 2.0) == Float64
        #     @test eltype(a / 2.0) == Float64
        # end
        let a = broadcast(Float32, SVector(3, 4, 5))
            @test eltype(a) == Float32
        end
    end
end
