abstract type AbstractTriple{T} <: MultipartFloat{T} end

struct Triple{T<:SysFloat, E<:Emphasis} <: AbstractTriple{T}
    hi::T   # highest significance
    md::T   # medium  significance
    lo::T   # lowest  significance
end

@inline hi(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.hi
@inline md(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.md
@inline lo(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.lo
