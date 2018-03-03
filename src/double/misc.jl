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
