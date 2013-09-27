module TwoFloat

export Double, Split, double, split
import Base.convert, Base.*, Base.+, Base./, Base.sqrt, Base.rem, Base.rand, Base.promote_rule

typealias BitsFloat Union(Float32,Float64) # Floating point BitTypes
abstract Two{T} <: FloatingPoint

# In a Split, hi uses only half of the mantissa (hence x.hi * y.hi will be exact).
immutable Split{T<:BitsFloat} <: Two{T}
    hi::T
    lo::T
end

# In a Double, hi uses the full mantissa, and abs(lo) <= 0.5eps(hi)
immutable Double{T<:BitsFloat} <: Two{T}
    hi::T
    lo::T
end

# round floats to half-precision
halfprec(x::Float64) = (p = x*1.34217729e8; (x-p)+p) # signif(x,26,2)
halfprec(x::Float32) = (p = x*4097f0; (x-p)+p) # float32(signif(x,12,2))

convert{T<:BitsFloat}(::Type{Double{T}}, x::T) = Double(x,zero(x))
convert{T<:BitsFloat}(::Type{Double{T}}, x::Double{T}) = x # needed because Double <: FLoatingPoint
function convert{T<:BitsFloat}(::Type{Double{T}}, x::FloatingPoint)
    z = oftype(T,x)
    Double(z,oftype(T,x-z))
end
convert{T<:BitsFloat}(::Type{T}, x::Double{T}) = x.hi

convert{T<:BitsFloat}(::Type{Split{T}}, x::Split{T}) = x 
function convert{T<:BitsFloat}(::Type{Split{T}}, x::FloatingPoint)
    z = halfprec(oftype(T,x))
    Split(z,oftype(T,x-z))
end
convert{T<:BitsFloat}(::Type{T}, x::Split{T}) = x.hi + x.lo

convert{T<:BitsFloat}(::Type{Double{T}}, x::Split{T}) = double(x.hi, x.lo)
function convert{T<:BitsFloat}(::Type{Split{T}}, x::Double{T}) 
    z = halfprec(x.hi)
    Split(z, (x.hi - z) + x.lo)
end

convert{T<:BitsFloat}(::Type{BigFloat}, x::Two{T}) = big(x.hi) + big(x.lo)


split(x::BitsFloat) = convert(Split{typeof(x)},x)
double(x::BitsFloat) = convert(Double{typeof(x)},x)


promote_rule{T<:BitsFloat}(::Type{Split{T}}, ::Type{T}) = Split{T}
promote_rule{T<:BitsFloat}(::Type{Double{T}}, ::Type{T}) = Double{T}
promote_rule{T<:BitsFloat}(::Type{Split{T}}, ::Type{BigFloat}) = BigFloat
promote_rule{T<:BitsFloat}(::Type{Double{T}}, ::Type{BigFloat}) = BigFloat
promote_rule{s,T<:Two}(::Type{MathConst{s}}, ::Type{T}) = T

# "Normalise" doubles to ensure abs(lo) <= 0.5eps(hi)
# assumes abs(v) << abs(u)
# this could be moved to the constructor if necessary
function double{T<:BitsFloat}(u::T,v::T) 
    w = u + v
    Double(w,(u-w) + v)
end
function split{T<:BitsFloat}(u::T,v::T) 
    w = halfprec(u + v)
    Double(w,(u-w) + v)
end


split(x::BigFloat) = convert(Split{Float64},x)
double(x::BigFloat) = convert(Double{Float64},x)
split{S}(x::MathConst{S}) = convert(Split{Float64},x)
double{S}(x::MathConst{S}) = convert(Double{Float64},x)


# Dekker add2
function +{T<:BitsFloat}(x::Double{T}, y::Double{T})
    r = x.hi + y.hi
    s = abs(x) > abs(y) ? (((x.hi - r) + y.hi) + y.lo) + x.lo : (((y.hi - r) + x.hi) + x.lo) + y.lo
    z = r + s
    Double(z, (r - z) + s)
end

# the product of two Splits that are equivalent to Float64s gives an exact Double
# Dekker mul12
function *{T<:BitsFloat}(x::Split{T}, y::Split{T})
    p = x.hi * y.hi
    q = x.hi * y.lo + x.lo * y.hi
    z = p + q
    Double(z, ((p-z)+q)+x.lo*y.lo )
end

# Dekker mul2
function *{T<:BitsFloat}(x::Double{T}, y::Double{T})
    c = split(x.hi) * split(y.hi)
    cc = (x.hi * y.lo + x.lo* y.hi) + c.lo
    double(c.hi, cc)
end

# Dekker div2
function /{T<:BitsFloat}(x::Double{T}, y::Double{T})
    c = x.hi / y.hi
    u = split(c) * split(y.hi)
    cc = ((((x-u.hi) - u.lo) + x.lo) - c*y.lo)/y.hi
    double(c,cc)
end

# Dekker sqrt2
function sqrt{T<:BitsFloat}(x::Double{T})
    if x.hi <= 0
        throw(DomainError("sqrt will only return a complex result if called with a complex argument."))
    end
    c = sqrt(x.hi)
    sc = split(c)
    u = sc*sc
    cc = (((x.hi - u.hi) - u.lo) + x.lo)*0.5/c
    double(c,cc)
end


rem{T<:BitsFloat}(x::Double{T},d::Real) = double(rem(x.hi,d),rem(x.lo,d))

# random numbers using full Uint64 range
function rand(::Type{Double{Float64}})
    u = rand(Uint64)
    f = float64(u)
    uf = uint64(f)
    ur = uf > u ? uf-u : u-uf
    Double(5.421010862427522e-20*f, 5.421010862427522e-20*float64(ur))
end
rand(::Type{Split{Float64}}) = split(rand(Double{Float64}))


# calculate constants from big numbers
macro twofloat_const_frombig(sym)
    esym = esc(sym)
    qsym = esc(Expr(:quote, sym))
    bigval = @eval big($sym)
    quote
        Base.convert(::Type{Split{Float64}}, ::MathConst{$qsym}) = $(convert(Split{Float64}, bigval))
        Base.convert(::Type{Split{Float32}}, ::MathConst{$qsym}) = $(convert(Split{Float32}, bigval))
        Base.convert(::Type{Double{Float64}}, ::MathConst{$qsym}) = $(convert(Double{Float64}, bigval))
        Base.convert(::Type{Double{Float32}}, ::MathConst{$qsym}) = $(convert(Double{Float32}, bigval))        
    end
end


@twofloat_const_frombig π
@twofloat_const_frombig e
@twofloat_const_frombig γ
@twofloat_const_frombig catalan
@twofloat_const_frombig φ

end #module

