
module DoubleDouble

export Double, FastDouble

# these imports are used broadly, other imports reside within source files
import Base: (+), (-), (*), (/)

const SysFloat = Union{Float16, Float32, Float64}
# this is present to help avoid things that should not be handled
# when the package is somewhat stable, we should try replacing this
# with `const SysReal = Real` and see if everything continues well
const SysReal  = Union{Signed, BigInt, AbstractFloat, Rational, Irrational}

# Algorithmic choice is a Trait
abstract type Trait end
abstract type Emphasis <: Trait end
struct Accuracy    <: Emphasis end
struct Performance <: Emphasis end

const EMPHASIS     = Accuracy    # this is the default Emphasis
const ALT_EMPHASIS = Performance

const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"

abstract type AbstractDouble{T} <: AbstractFloat end

struct Double{T<:SysFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

Double(hi::T, lo::T) where T<:SysFloat = Double(EMPHASIS, hi, lo)

function Double(::Type{E}, hi::T, lo::T) where {T<:SysFloat, E<:Emphasis}
    s = hi + lo
    e = (hi - s) + lo
    return Double{T,E}(s, e)
end

function Double(::Type{E}, hi::T) where {T<:SysFloat, E<:Emphasis}
    return Double{T,E}(hi, zero(T))
end

function Double(::Type{E}, hi::T, lo::T) where {T<:Signed, E<:Emphasis}
    return Double(E, float(hi), float(lo))
end
function Double(::Type{E}, hi::T) where {T<:Signed, E<:Emphasis}
    return Double(E, float(hi), float(zero(T)))
end

function Double(::Type{E}, hi::T, lo::T) where {T<:SysReal, E<:Emphasis}
    s = Float64(hi + lo)
    e = Float64((hi - T(s)) + lo)
    return Double{Float64,E}(s,e)
end
function Double(::Type{E}, hi::T) where {T<:SysReal, E<:Emphasis}
    s = Float64(hi)
    e = Float64(hi - T(s))
    return Double{Float64,E}(s,e)
end

function Double(::Type{E}, hi::T, lo::T) where {T<:Rational, E<:Emphasis}
    return Double(E, BigFloat(hi), BigFloat(lo))
end
function Double(::Type{E}, hi::T) where {T<:Rational, E<:Emphasis}
    return Double(E, BigFloat(hi))
end

Double(x::S) where S<:SysFloat = Double(EMPHASIS, x)
Double(x::R) where R<:SysReal  = Double(EMPHASIS, x)
Double(x::S, y::S) where S<:SysFloat = Double(EMPHASIS, x)
Double(x::R, y::R) where R<:SysReal  = Double(EMPHASIS, x, y)

FastDouble(x::R) where R<:SysReal       = Double(Performance, x)
FastDouble(x::R, y::R) where R<:SysReal = Double(Performance, x, y)


function Base.string(x::Double{T,EMPHASIS}) where T<:SysFloat
    return string(EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.string(x::Double{T,ALT_EMPHASIS}) where T<:SysFloat
    return string(ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.show(io::IO, x::Double{T,E}) where  {T<:SysFloat, E<:Emphasis}
    print(io, string(x))
end

include("convert.jl")

end # module
