abstract type AbstractTriple{T} <: MultipartFloat{T} end

struct Triple{T<:SysFloat, E<:Emphasis} <: AbstractTriple{T}
    hi::T   # highest significance
    md::T   # medium  significance
    lo::T   # lowest  significance
end

@inline hi(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.hi
@inline md(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.md
@inline lo(x::Triple{T,E}) where {T<:SysFloat, E<:Emphasis} = x.lo

@inline md(x::T) where T<:SysFloat = zero(T)

@inline Triple(::Type{E}, a::T, b::T, c::T) where {T<:SysFloat, E<:Emphasis} = Triple{T,E}(a,b,c)
@inline Triple(::Type{E}, a::T, b::T) where {T<:SysFloat, E<:Emphasis} = Triple{T,E}(a,b,zero(T))
@inline Triple(::Type{E}, a::T) where {T<:SysFloat, E<:Emphasis} = Triple{T,E}(a,zero(T),zero(T))

function Base.string(x::Triple{T,EMPHASIS}) where T<:SysFloat
    return string(EMPHASIS_STR,"Triple(",x.hi,", ",x.md,", ",x.lo,")")
end
function Base.string(x::Triple{T,ALT_EMPHASIS}) where T<:SysFloat
    return string(ALT_EMPHASIS_STR,"Triple(",x.hi,", ",x.md,", ",x.lo,")")
end
function Base.show(io::IO, x::Triple{T,E}) where  {T<:SysFloat, E<:Emphasis}
    print(io, string(x))
end
