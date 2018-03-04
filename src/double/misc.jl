function Base.rand(rng::AbstractRNG, S::Type{Double{Float64, E}}) where {E<:Emphasis}
    u = rand(rng, UInt64)
    f = Float64(u)
    uf = UInt64(f)
    ur = uf > u ? uf - u : u - uf
    Double{Float64, E}(5.421010862427522e-20 * f, 5.421010862427522e-20 * Float64(ur))
end

function Base.rand(rng::AbstractRNG, S::Type{Double{Float32, E}}) where {E<:Emphasis}
    u = rand(rng, UInt32)
    f = Float32(u)
    uf = UInt32(f)
    ur = uf > u ? uf - u : u - uf
    Double{Float32, E}(5.421010862427522e-20 * f, 5.421010862427522e-20 * Float32(ur))
end
Base.rand(rng::AbstractRNG, ::Type{Double{T}}) where T = rand(rng, Double{T, EMPHASIS})



@eval begin
    Base.typemax(::Type{Double{Float32, Accuracy}}) = Inf32x2
    Base.typemax(::Type{Double{Float32, Performance}}) = FastInf32x2
    Base.typemax(::Type{Double{Float64, Accuracy}}) = Inf64x2
    Base.typemax(::Type{Double{Float64, Performance}}) = FastInf64x2

    Base.typemin(::Type{Double{Float32, Accuracy}}) = $(-Inf32x2)
    Base.typemin(::Type{Double{Float32, Performance}}) = $(-FastInf32x2)
    Base.typemin(::Type{Double{Float64, Accuracy}}) = $(-Inf64x2)
    Base.typemin(::Type{Double{Float64, Performance}}) = $(-FastInf64x2)
end

for E in [Accuracy, Performance]
    @eval begin
        Base.realmax(::Type{Double{Float32, $E}}) = $(Double(E, realmax(Float32), ldexp(1.0f0, 102)))
        Base.realmax(::Type{Double{Float64, $E}}) = $(Double(E, realmax(Float64), ldexp(1.0, 970)))

        Base.realmin(::Type{Double{Float32, $E}}) = $(Double(E, realmin(Float32)))
        Base.realmin(::Type{Double{Float64, $E}}) = $(Double(E, realmin(Float64)))

        # I am not sure these are completely correct
        Base.eps(::Type{Double{Float32, $E}}) = $(Double(E, ldexp(1.0f0, -46)))
        Base.eps(::Type{Double{Float64, $E}}) = $(Double(E, ldexp(1.0, -104)))
    end
end
