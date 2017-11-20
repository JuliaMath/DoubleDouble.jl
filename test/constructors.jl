@testset "Constructors" begin
    @test Double(2.0) isa Double{Float64, Fast}
    @test Double(2.0, Accurate) isa Double{Float64, Accurate}
    @test Double{Float64}(2.0) isa Double{Float64, Fast}
    @test Double(2.0, Accurate) isa Double{Float64, Accurate}
    @test Double(2.0f0) isa Double{Float32, Fast}
    @test Double(2.0f0, Accurate) isa Double{Float32, Accurate}
    @test Double{Float64}(2.0f0) isa Double{Float64, Fast}
    @test Double{Float64}(2.0f0, Accurate) isa Double{Float64, Accurate}
    @test Double(π, Fast) isa Double{Float64, Fast}
    @test Double(π, Accurate) isa Double{Float64, Accurate}
    @test Double{Float32}(π, Fast) isa Double{Float32, Fast}
    @test Double{Float32}(π, Accurate) isa Double{Float32, Accurate}
    @test Double(big(π), Fast) isa Double{Float64, Fast}
    @test Double(big(π), Accurate) isa Double{Float64, Accurate}
    @test Double{Float32}(rand(), Fast) isa Double{Float32, Fast}
    @test Double{Float32}(rand(), Accurate) isa Double{Float32, Accurate}
    @test Double{Float32}(big(π), Fast) isa Double{Float32, Fast}
    @test Double{Float32}(big(π), Accurate) isa Double{Float32, Accurate}
    @test Double(1//3, Fast) isa Double{Float64, Fast}
    @test Double(1//3, Accurate) isa Double{Float64, Accurate}
    @test Double{Float32}(1//3, Fast) isa Double{Float32, Fast}
    @test Double{Float32}(1//3, Accurate) isa Double{Float32, Accurate}
end
