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

#=
   algorithm 3.3 from Basic building blocks for a triple-double intermediate format

   preconditions
   hi, md, lo are normal floating point values
   |md| <= |hi| * 0.25
   |lo| <= |md| * 0.25
   |lo| <= |hi| * 0.0625
=#
@inline function renormalize(hi::T, md::T, lo::T) where {T<:SysFloat}
    hi1, lo1 = two_sum_hilo(md, lo)
    hi, lo = two_sum_hilo(hi, hi1)
    md, lo = two_sum_hilo(lo, lo1)
    return hi, md, lo
end

function normalize(a::T, b::T, c::T) where {T<:SysFloat}
    b, c = abs(b) < abs(c) ? (b, c) : (c, b)
    a, c = abs(a) < abs(c) ? (a, c) : (c, a)
    a, b = abs(a) < abs(b) ? (a, b) : (b, a)
    a, b, c = renormalize(c, b, a) # to meet preconditions
    a, b, c = renormalize(a, b, c) # final renormalization ??is this needed??
    return a, b, c
end

function Base.string(x::Triple{T,EMPHASIS}) where T<:SysFloat
    return string(EMPHASIS_STR,"Triple(",x.hi,", ",x.md,", ",x.lo,")")
end
function Base.string(x::Triple{T,ALT_EMPHASIS}) where T<:SysFloat
    return string(ALT_EMPHASIS_STR,"Triple(",x.hi,", ",x.md,", ",x.lo,")")
end
function Base.show(io::IO, x::Triple{T,E}) where  {T<:SysFloat, E<:Emphasis}
    print(io, string(x))
end
