__precompile__()

module DoubleDouble

export Double, DoubleF32, DoubleF64, FastDouble, Emphasis, Accuracy, Performance,
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

abstract type MultipartFloat{T}    <: AbstractFloat end
abstract type AbstractDouble{T}    <: MultipartFloat{T} end

include("float/eps_ufp_ulp.jl")
include("float/errorfree.jl")
include("float/errorbest.jl")

include("double/type.jl")
include("double/show.jl")
include("double/ZeroInfNan.jl")
include("double/constructors.jl")
include("double/convert.jl")
include("double/float_arith.jl")
# include("double/primitive.jl")
include("double/compare.jl")
include("double/arith_dd_fl.jl")
include("double/arith_dd_dd.jl")
include("double/floorceiltrunc.jl")
include("double/round.jl")
include("double/misc.jl")

#include("interwork/bigfloat.jl")

end # module
