__precompile__()

module DoubleDouble

export Double, ComputeMode, Fast, Accurate

abstract type ComputeMode end
struct Fast <: ComputeMode end
struct Accurate <: ComputeMode end

const CM = ComputeMode
const SysFloat = Union{Float64, Float32}

struct Double{T<:SysFloat, M<:ComputeMode} <: AbstractFloat
    hi::T
    lo::T
end

# constructors
function Double{T}(x::Number, M::Type{<:CM}=Fast) where {T<:SysFloat}
    Double{T, M}(convert(T, x), isinf(x) ? convert(T, Inf) : zero(T))
end

function Double{Float32}(x::Float64, M::Type{<:CM}=Fast)
    z = convert(Float32, x)
    Double{Float32, M}(u, convert(Float32, x - z))
end

Double(u::T, v::T, M::Type{<:CM}=Fast) where {T<:SysFloat} = Double{T, M}(u, v)
function Double(x::BigFloat, M::Type{<:CM}=Fast)
    z = convert(Float64, x)
    Double{Float64, M}(z, convert(Float64, x - z))
end
function Double(x::T, M::Type{<:CM}=Fast) where {T<:SysFloat}
    Double{T, M}(x, isinf(x) ? convert(T, Inf) : zero(T))
end
Double(x::Number, M::Type{<:CM}=Fast) = Double{Float64}(x, M)

end
