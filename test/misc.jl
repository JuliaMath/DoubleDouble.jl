@testset "misc" begin
    for T in [Float32, Float64]
        @test rand(Double{T}) isa Double{T, DoubleDouble.EMPHASIS}
        for E in [Performance, Accuracy]
            @test rand(Double{T, E}) isa Double{T, E}
            @test eps(Double{T, E}) isa Double{T, E}
            @test typemax(Double{T, E}) isa Double{T, E}
            @test typemin(Double{T, E}) isa Double{T, E}
            @test realmax(Double{T, E}) isa Double{T, E}
            @test realmin(Double{T, E}) isa Double{T, E}
        end
    end
end
