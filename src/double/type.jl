struct Double{T<:SysFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E} = x.hi
@inline lo(x::Double{T,E}) where {T,E} = x.lo

@inline hi(x::T) where T<:SysFloat = x
@inline lo(x::T) where T<:SysFloat = zero(T)
