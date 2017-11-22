const one32 = one(Float32)
const one64 = one(Float64)

@testset "Constructors" begin
    @test Double(one64) isa Double{Float64, DoubleDouble.EMPHASIS}
    @test Double(1) isa Double{Float64, DoubleDouble.EMPHASIS}
    @test Double(1.0) isa Double{Float64, DoubleDouble.EMPHASIS}
    @test Double(Accuracy, 1.0) isa Double{Float64, Accuracy}
    @test Double(Performance, 1.0) isa Double{Float64, Performance}
    @test Double(Accuracy, one64) isa Double{Float64, Accuracy}
    @test Double(Performance, one64) isa Double{Float64, Performance}

    @test Double(one32) isa Double{Float32, DoubleDouble.EMPHASIS}
    @test Double(Accuracy, 1.0f0) isa Double{Float32, Accuracy}
    @test Double(Performance, 1.0f0) isa Double{Float32, Performance}
    @test Double(1.0f0) isa Double{Float32, DoubleDouble.EMPHASIS}
    @test Double(Accuracy, one32) isa Double{Float32, Accuracy}
    @test Double(Performance, one32) isa Double{Float32, Performance}

    @test Double(π) isa Double{Float64, DoubleDouble.EMPHASIS}
    @test Double(Accuracy, π) isa Double{Float64, Accuracy}
    @test Double(Performance, π) isa Double{Float64, Performance}
    @test Double(Accuracy, big(π)) isa Double{Float64, Accuracy}
    @test Double(Performance, big(π)) isa Double{Float64, Performance}
    @test Double(Accuracy, 1//3) isa Double{Float64, Accuracy}
    @test Double(Performance, 1//3) isa Double{Float64, Performance}

    @test FastDouble(π) isa Double{Float64, Performance}
    @test FastDouble(2.3f0, 0.12f0) isa Double{Float32, Performance}
end
