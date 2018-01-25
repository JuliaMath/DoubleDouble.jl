module DoubleDouble

export Double, FastDouble, Emphasis, Accuracy, Performance,
       hi, lo,
       square, cube, tld, rld, ufp, ulp, slp

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

const EMPHASIS     = Accuracy      # this is the default Emphasis
const ALT_EMPHASIS = Performance   # this is the other Emphasis 

const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"    # and prepend "Double"

abstract type MultipartFloat{T}    <: AbstractFloat end
abstract type AbstractDouble{T}    <: MultipartFloat{T} end

struct Double{T<:SysFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E} = x.hi
@inline lo(x::Double{T,E}) where {T,E} = x.lo

@inline hi(x::T) where T<:SysFloat = x
@inline lo(x::T) where T<:SysFloat = zero(T)

function Base.string(x::Double{T,EMPHASIS}) where T<:SysFloat
    return string(EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.string(x::Double{T,ALT_EMPHASIS}) where T<:SysFloat
    return string(ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.show(io::IO, x::Double{T,E}) where  {T<:SysFloat, E<:Emphasis}
    print(io, string(x))
end

include("float/eps_ufp_ulp.jl")
include("float/errorfree.jl")
include("float/errorbest.jl")

include("double/ZeroInfNan.jl")
include("double/constructors.jl")
include("double/convert.jl")
include("double/float_arith.jl")
include("double/primitive.jl")
include("double/compare.jl")
include("double/arith_dd_fl.jl")
include("double/arith_dd_dd.jl")
include("double/floorceiltrunc.jl")
include("double/round.jl")

#include("interwork/bigfloat.jl")

end # module
