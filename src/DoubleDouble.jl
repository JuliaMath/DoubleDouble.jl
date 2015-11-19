module DoubleDouble

export Double, Single, double
import Base.convert, Base.*, Base.+, Base./, Base.sqrt, Base.rem, Base.rand, Base.promote_rule

typealias BitsFloat Union{BigFloat,Float32,Float64} # Floating point BitTypes AbstractFloat

abstract AbstractDouble{T} <: AbstractFloat


# a Single is a wrapper for an ordinary floating point type such that arithmetic operations will return Doubles
immutable Single{T<:BitsFloat} <: AbstractDouble{T}
    hi::T
end

# In a Double, hi uses the full mantissa, and abs(lo) <= 0.5eps(hi)
immutable Double{T<:BitsFloat} <: AbstractDouble{T}
    hi::T
    lo::T
end
Double{T<:BitsFloat}(x::T) = Double(x,zero(T))

const half64 = 1.34217729e8
const half32 = 4097f0
const halfBig = 3.402823669209384634633746074317682114570000000000000000000000000000000000000000e+38
# 6.805647338418769269267492148635364229120000000000000000000000000000000000000000e38

# round floats to half-precision
# TODO: fix overflow for large values
halfprec(x::Float64) = (p = x*half64; (x-p)+p) # signif(x,26,2) for 26 is 6.7108865e7, this seems like 27
halfprec(x::Float32) = (p = x*half32; (x-p)+p) # float32(signif(x,12,2))
halfprec(x::BigFloat) = (p = x*halfBig; (x-p)+p) # BigFloat(signif(x,12,2))

function splitprec(x::BitsFloat)
    h = halfprec(x)
    h, x-h
end


## conversion and promotion
convert{T<:BitsFloat}(::Type{Single{T}}, x::T) = Single(x)
convert{T<:BitsFloat}(::Type{Double{T}}, x::T) = Double(x)

convert{T<:BitsFloat}(::Type{Double{T}}, x::Single{T}) = Double(x.hi)
convert{T<:BitsFloat}(::Type{Single{T}}, x::Double{T}) = Single(x.hi)

convert{T<:BitsFloat}(::Type{T}, x::AbstractDouble{T}) = x.hi

convert{T<:BitsFloat}(::Type{Single{T}}, x::Single{T}) = x # needed because Double <: FloatingPoint
convert{T<:BitsFloat}(::Type{Double{T}}, x::Double{T}) = x # needed because Double <: FloatingPoint

convert{T<:BitsFloat}(::Type{Single{T}}, x::AbstractFloat) = Single(convert(T,x))

function convert{T<:BitsFloat}(::Type{Double{T}}, x::AbstractFloat)
    z = convert(T,x)
    Double(z,convert(T,x-z))
end

convert{T<:BitsFloat}(::Type{BigFloat}, x::Single{T}) = big(x.hi)
convert{T<:BitsFloat}(::Type{BigFloat}, x::Double{T}) = big(x.hi) + big(x.lo)


promote_rule{T<:BitsFloat}(::Type{Single{T}}, ::Type{T}) = Single{T}
promote_rule{T<:BitsFloat}(::Type{Double{T}}, ::Type{T}) = Double{T}
promote_rule{T<:BitsFloat}(::Type{Double{T}}, ::Type{Single{T}}) = Double{T}

# promote_rule{T<:BitsFloat}(::Type{AbstractDouble{T}}, ::Type{BigFloat}) = BigFloat  !!
promote_rule{s,T<:BitsFloat}(::Type{Irrational{s}}, ::Type{Single{T}}) = Double{BigFloat}

double(x::BitsFloat) = Double(x)
# "Normalise" doubles to ensure abs(lo) <= 0.5eps(hi)
# assumes abs(u) > abs(v): if not, use Single + Single
# could be moved to the constructor?
function double{T<:BitsFloat}(u::T,v::T) 
    w = u + v
    Double(w,(u-w) + v)
end
double(x::BigFloat) = convert(Double{BigFloat},x)
double{S}(x::Irrational{S}) = convert(Double{BigFloat},x)

# add12
function +{T}(x::Single{T},y::Single{T})
    abs(x.hi) > abs(y.hi) ? double(x.hi,y.hi) : double(y.hi,x.hi)
end

# Dekker add2
function +{T}(x::Double{T}, y::Double{T})
    r = x.hi + y.hi
    s = abs(x.hi) > abs(y.hi) ? (((x.hi - r) + y.hi) + y.lo) + x.lo : (((y.hi - r) + x.hi) + x.lo) + y.lo
    double(r,s)
end

# add122 
function +{T}(x::Single{T}, y::Double{T})
    r = x.hi + y.hi
    s = abs(x.hi) > abs(y.hi) ? ((x.hi - r) + y.hi) + y.lo : ((y.hi - r) + x.hi) + y.lo
    double(r,s)
end
+{T}(x::Double{T}, y::Single{T}) = y + x


-{T<:BitsFloat}(x::Double{T}) = Double(-x.hi,-y.hi)

function -{T}(x::Double{T}, y::Double{T})
    r = x.hi - y.hi
    s = abs(x.hi) > abs(y.hi) ? (((x.hi - r) - y.hi) - y.lo) + x.lo : (((-y.hi - r) + x.hi) + x.lo) - y.lo
    double(r,s)
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
    double(c.hi, cc)
end

# Dekker div2
function /{T}(x::Double{T}, y::Double{T})
    c = x.hi / y.hi
    u = Single(c) * Single(y.hi)
    cc = ((((x.hi - u.hi) - u.lo) + x.lo) - c*y.lo)/y.hi
    double(c,cc)
end

# Dekker sqrt2
function sqrt{T}(x::Double{T})
    if x.hi <= 0
        throw(DomainError("sqrt will only return a complex result if called with a complex argument."))
    end
    c = sqrt(x.hi)
    u = Single(c)*Single(c)
    cc = (((x.hi - u.hi) - u.lo) + x.lo)*map(typeof(x.hi),0.5)/c
    double(c,cc)
end


rem{T}(x::Double{T},d::Real) = double(rem(x.hi,d),rem(x.lo,d))

# random numbers using full Uint64 range
function rand(::Type{Double{Float64}})
    u = rand(Uint64)
    f = float64(u)
    uf = uint64(f)
    ur = uf > u ? uf-u : u-uf
    Double(5.421010862427522e-20*f, 5.421010862427522e-20*float64(ur))
end

# calculate constants from big numbers
macro twofloat_const_frombig(sym)
    esym = esc(sym)
    qsym = esc(Expr(:quote, sym))
    bigval = @eval big($sym)
    quote
        Base.convert(::Type{Double{Float64}}, ::Irrational{$qsym}) = $(convert(Double{Float64}, bigval))
        Base.convert(::Type{Double{Float32}}, ::Irrational{$qsym}) = $(convert(Double{Float32}, bigval))
        Base.convert(::Type{Double{BigFloat}}, ::Irrational{$qsym}) = $(convert(Double{BigFloat}, bigval)) 
    end
end

@twofloat_const_frombig π
@twofloat_const_frombig e
@twofloat_const_frombig γ
@twofloat_const_frombig catalan
@twofloat_const_frombig φ

end #module

