@testset "misc" begin
    @test rand(Double{Float64, Accuracy}) isa Double{Float64, Accuracy}
    @test rand(Double{Float64, Performance}) isa Double{Float64, Performance}
    @test rand(Double{Float64}) isa Double{Float64, DoubleDouble.EMPHASIS}

    @test rand(Double{Float32, Accuracy}) isa Double{Float32, Accuracy}
    @test rand(Double{Float32, Performance}) isa Double{Float32, Performance}
    @test rand(Double{Float32}) isa Double{Float32, DoubleDouble.EMPHASIS}
end
