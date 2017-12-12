module DoubleDouble

export Double, FastDouble, Emphasis, Accuracy, Performance,
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

const EMPHASIS     = Accuracy    # this is the default Emphasis
const ALT_EMPHASIS = Performance

const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"

abstract type AbstractDouble{T} <: AbstractFloat end

struct Double{T<:SysFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline Base.isinf(x::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = isinf(x.hi)
@inline Base.isnan(x::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = isnan(x.hi)
Base.eps(x::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = iszero(x.lo) ? eps(x.hi) : eps(x.lo)


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

end # module
