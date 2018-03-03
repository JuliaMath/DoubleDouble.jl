struct Double{T<:SysFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end
const DoubleF32{E<:Emphasis} = Double{Float32, E}
const DoubleF64{E<:Emphasis} = Double{Float64, E}

@inline hi(x::Double{T,E}) where {T,E} = x.hi
@inline lo(x::Double{T,E}) where {T,E} = x.lo

@inline hi(x::T) where T<:SysFloat = x
@inline lo(x::T) where T<:SysFloat = zero(T)
