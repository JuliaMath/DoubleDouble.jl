module DoubleDouble

export Double, Single
import Base:
    convert,
    *, +, -, /, sqrt, <,
    rem, abs, rand, promote_rule,
    show, big

abstract AbstractDouble{T} <: Real

# a Single is a wrapper for an ordinary floating point type such that arithmetic operations will return Doubles
immutable Single{T<:AbstractFloat} <: AbstractDouble{T}
    hi::T
end

# In a Double, hi uses the full mantissa, and abs(lo) <= 0.5eps(hi)
immutable Double{T<:AbstractFloat} <: AbstractDouble{T}
    hi::T
    lo::T

    # "Normalise" Doubles to ensure abs(lo) <= 0.5eps(hi)
    # assumes abs(u) > abs(v): if not, use Single + Single
    function Double(u::T, v::T)
        w = u + v
        new(w, (u-w) + v)
    end
end

# constructors
Double{T<:AbstractFloat}(u::T, v::T) = Double{T}(u, v)
Double{T<:AbstractFloat}(x::T) = Double(x, zero(T))


const half64 = 1.34217729e8
const half32 = 4097f0
const half16 = Float16(33.0)
const halfBig = 3.402823669209384634633746074317682114570000000000000000000000000000000000000000e+38
# 6.805647338418769269267492148635364229120000000000000000000000000000000000000000e38

# round floats to half-precision
# TODO: fix overflow for large values
halfprec(x::Float64) = (p = x*half64; (x-p)+p) # signif(x,26,2) for 26 is 6.7108865e7, this seems like 27
halfprec(x::Float32) = (p = x*half32; (x-p)+p) # float32(signif(x,12,2))
halfprec(x::Float16) = (p = x*half16; (x-p)+p) # float16(signif(x,5,2))
halfprec(x::BigFloat) = (p = x*halfBig; (x-p)+p) # BigFloat(signif(x,128,2))

function splitprec(x::AbstractFloat)
    h = halfprec(x)
    h, x-h
end


# ones(T::Double, dims...) = fill!(Array(T, dims...), (one)(T))
# zeros(T::Double, dims...) = fill!(Array(T, dims...), (zero)(T))



## promotion
promote_rule{T<:AbstractFloat}(::Type{Double{T}}, ::Type{Int64}) = Double{T}

## conversion

convert{T<:AbstractFloat}(::Type{Single{T}}, x::T) = Single(x)
convert{T<:AbstractFloat}(::Type{Double{T}}, x::T) = Double(x)

convert{T<:AbstractFloat}(::Type{Double{T}}, x::Single{T}) = Double(x.hi)
convert{T<:AbstractFloat}(::Type{Single{T}}, x::Double{T}) = Single(x.hi)

convert{T<:AbstractFloat}(::Type{T}, x::AbstractDouble{T}) = x.hi

convert{T<:AbstractFloat}(::Type{Single{T}}, x::Single{T}) = x # needed because Double <: FloatingPoint
convert{T<:AbstractFloat}(::Type{Double{T}}, x::Double{T}) = x # needed because Double <: FloatingPoint

convert{T<:AbstractFloat}(::Type{Single{T}}, x::AbstractFloat) = Single(convert(T,x))

function convert{T<:AbstractFloat}(::Type{Double{T}}, x::AbstractFloat)
    z = convert(T, x)
    Double(z, convert(T, x-z))
end

convert{T<:AbstractFloat}(::Type{Double{T}}, x::Irrational) = convert(Double{T}, big(x))

convert(::Type{BigFloat}, x::Single) = big(x.hi)
convert(::Type{BigFloat}, x::Double) = big(x.hi) + big(x.lo)

convert{T}(::Type{Single{T}}, x::Integer) = convert(Single{T}, T(x))
convert{T}(::Type{Double{T}}, x::Integer) = convert(Double{T}, T(x))

promote_rule{T<:AbstractFloat}(::Type{Single{T}}, ::Type{T}) = Single{T}
promote_rule{T<:AbstractFloat}(::Type{Double{T}}, ::Type{T}) = Double{T}
promote_rule{T<:AbstractFloat}(::Type{Double{T}}, ::Type{Single{T}}) = Double{T}

# promote_rule{T<:AbstractFloat}(::Type{AbstractDouble{T}}, ::Type{BigFloat}) = BigFloat  !!
promote_rule{s,T<:AbstractFloat}(::Type{Irrational{s}}, ::Type{Single{T}}) = Double{Float64}


Single(x::Real) = convert(Single{Float64}, Float64(x))

Double(x::Real) = convert(Double{Float64}, Float64(x))
Double(x::BigFloat) = convert(Double{Float64}, x)
Double(x::Irrational) = convert(Double{Float64}, x)

# <

function <{T}(x::Double{T}, y::Double{T})
    x.hi + x.lo < y.hi + y.lo
end

# add12
function +{T}(x::Single{T},y::Single{T})
    abs(x.hi) > abs(y.hi) ? Double(x.hi, y.hi) : Double(y.hi, x.hi)
end

# Dekker add2
function +{T}(x::Double{T}, y::Double{T})
    r = x.hi + y.hi
    s = abs(x.hi) > abs(y.hi) ? (((x.hi - r) + y.hi) + y.lo) + x.lo : (((y.hi - r) + x.hi) + x.lo) + y.lo
    Double(r, s)
end

# add122
function +{T}(x::Single{T}, y::Double{T})
    r = x.hi + y.hi
    s = abs(x.hi) > abs(y.hi) ? ((x.hi - r) + y.hi) + y.lo : ((y.hi - r) + x.hi) + y.lo
    Double(r, s)
end
+{T}(x::Double{T}, y::Single{T}) = y + x


-{T<:AbstractFloat}(x::Double{T}) = Double(-x.hi, -x.lo)

function -{T}(x::Double{T}, y::Double{T})
    r = x.hi - y.hi
    s = abs(x.hi) > abs(y.hi) ? (((x.hi - r) - y.hi) - y.lo) + x.lo : (((-y.hi - r) + x.hi) + x.lo) - y.lo
    Double(r, s)
end


# Dekker mul12
function *{T}(x::Single{T},y::Single{T})
    hx,lx = splitprec(x.hi)
    hy,ly = splitprec(y.hi)
    z = x.hi*y.hi
    Double(z, ((hx*hy-z) + hx*ly + lx*hy) + lx*ly)
end

# Dekker mul2
function *{T}(x::Double{T}, y::Double{T})
    c = Single(x.hi) * Single(y.hi)
    cc = (x.hi * y.lo + x.lo* y.hi) + c.lo
    Double(c.hi, cc)
end

# Dekker div2
function /{T}(x::Double{T}, y::Double{T})
    c = x.hi / y.hi
    u = Single(c) * Single(y.hi)
    cc = ((((x.hi - u.hi) - u.lo) + x.lo) - c*y.lo)/y.hi
    Double(c, cc)
end

# Dekker sqrt2
function sqrt{T}(x::Double{T})
    if x.hi <= 0
        throw(DomainError("sqrt will only return a complex result if called with a complex argument."))
    end
    c = sqrt(x.hi)
    u = Single(c)*Single(c)
    cc = (((x.hi - u.hi) - u.lo) + x.lo)*map(typeof(x.hi),0.5)/c
    Double(c, cc)
end


rem{T}(x::Double{T},d::Real) = Double(rem(x.hi,d), rem(x.lo,d))
abs{T}(x::Double{T})=x.hi>0 ?x:-x

# random numbers using full Uint64 range (respectively, UInt32, UInt16 and UInt128)
function rand(::Type{Double{Float64}})
    u = rand(UInt64)
    f = Float64(u)
    uf = UInt64(f)
    ur = uf > u ? uf-u : u-uf
    Double(5.421010862427522e-20*f, 5.421010862427522e-20*Float64(ur))
end

function rand(::Type{Double{Float32}})
    u = rand(UInt32)
    f = Float32(u)
    uf = UInt32(f)
    ur = uf > u ? uf-u : u-uf
    Double(2.3283064f-10*f, 2.3283064f-10*Float32(ur))
end

function rand(::Type{Double{Float16}})
    u = rand(UInt16)
    f = Float16(u)
    uf = UInt16(f)
    ur = uf > u ? uf-u : u-uf
    Double(Float16(1.526e-5)*f, Float16(1.526e-5)*Float16(ur))
end

function rand(::Type{Double{BigFloat}})
    u = rand(UInt128)
    f = BigFloat(u)
    uf = UInt128(f)
    ur = uf > u ? uf-u : u-uf
    Double(2.938735877055718769921841343055614194546663891930218803771879265696043148636818e-39*f, 2.938735877055718769921841343055614194546663891930218803771879265696043148636818e-39*BigFloat(ur))
end


# calculate constants from big numbers
macro twofloat_const_frombig(sym)
    esym = esc(sym)
    qsym = esc(Expr(:quote, sym))
    bigval = @eval big($sym)
    quote
        convert(::Type{Double{Float64}}, ::Irrational{$qsym}) = $(convert(Double{Float64}, bigval))
        convert(::Type{Double{Float32}}, ::Irrational{$qsym}) = $(convert(Double{Float32}, bigval))
        convert(::Type{Double{Float16}}, ::Irrational{$qsym}) = $(convert(Double{Float16}, bigval))
        convert(::Type{Double{BigFloat}}, ::Irrational{$qsym}) = $(convert(Double{BigFloat}, bigval))
    end
end

@twofloat_const_frombig π
@twofloat_const_frombig e
@twofloat_const_frombig γ
@twofloat_const_frombig catalan
@twofloat_const_frombig φ


big(x::Double) = BigFloat(x)

function show(io::IO, x::Double)
    println(io, "Double(", x.hi, ", ", x.lo, ")")
    print(io, " - value: ")
    @printf io "%.32g" convert(BigFloat, x)  # crude approximation to valid number of digits
end

end #module
