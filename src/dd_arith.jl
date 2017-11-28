import Base: signbit, sign, abs, (+) # (-), (*), (/), square, inv, div, rem, cld, fld, mod, divrem, fldmod, sqrt,

@inline signbit(a::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = signbit(a.hi)
@inline sign(a::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = sign(a.hi)
@inline abs(a::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = signbit(a) ? Double(E, -a.hi, -a.lo) : a

@inline function (-)(a::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    return Double(E, -a.hi, -a.lo)
end

function (+)(::Type{E}, a::T, b::T) where {T<:SysFloat, E<:Emphasis}
   hi, lo = two_sum(a, b)
   return Double(E, hi, lo)
end

@inline (+)(::Type{E}, a::Float64, b::Float32) where E<:Emphasis = (+)(E, a, Float64(b))
@inline (+)(::Type{E}, a::Float32, b::Float64) where E<:Emphasis = (+)(E, Float64(a), b)

function (+)(a::Double{T,E}, b::T) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_sum(a.hi, b)
    lo += a.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end

function (+)(a::T, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_sum(a, b.hi)
    lo += b.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end

@inline (+)(a::Double{Float64,E}, b::Float32) where E<:Emphasis = (+)(a, Float64(b))
@inline (+)(a::Float32, b::Double{Float64,E}) where E<:Emphasis = (+)(Float64(a), b)
@inline (+)(a::Double{Float32,E}, b::Float64) where E<:Emphasis = (+)(Double(E, Float64(a.hi), Float64(a.lo)), b)
@inline (+)(a::Float64, b::Double{Float32,E}) where E<:Emphasis = (+)(a, Double(E, Float64(b.hi), Float64(b.lo)))

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (+)(x::Double{T, E}, y::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_sum(x.hi, y.hi)
    thi, tlo = two_sum(x.lo, y.lo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return Double(E, hi, lo)
end

@inline (+)(a::Double{Float64,E}, b::Double{Float32,E}) where E<:Emphasis = (+)(a, Double(E, Float64(b.hi), Float64(b.lo)))
@inline (+)(a::Double{Float32,E}, b::Double{Float64,E}) where E<:Emphasis = (+)(Double(E, Float64(a.hi), Float64(b.hi)), b)

function add_hilofl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_sum(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function add_hilohilo(xhi::T, xlo::T, yhi::T, ylo::T) where T<:SysFloat
    hi, lo = two_sum(xhi, yhi)
    thi, tlo = two_sum(xlo, ylo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return hi, lo
end

#=
 @inline (+)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = (+)(E, a.hi, a.lo, b.hi, b.lo)

function (+)(a::Double{T1,E}, b::T2) where {T1<:SysFloat, T2<:SysFloat, E<:Emphasis}
    if sizeof(T2) > sizeof(T1)
       Double(E, T2(a.hi), T2(a.lo)) + b
    else
       a + T1(b)
   end
end
=#

function (-)(::Type{E}, a::T, b::T) where {T<:SysFloat, E<:Emphasis}
   hi, lo = two_diff(a, b)
   return Double(E, hi, lo)
end

@inline (-)(::Type{E}, a::Float64, b::Float32) where E<:Emphasis = (-)(E, a, Float64(b))
@inline (-)(::Type{E}, a::Float32, b::Float64) where E<:Emphasis = (-)(E, Float64(a), b)

function (-)(a::Double{T,E}, b::T) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_diff(a.hi, b)
    lo += a.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end

function (-)(a::T, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_diff(a, b.hi)
    lo += b.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end

@inline (-)(a::Double{Float64,E}, b::Float32) where E<:Emphasis = (-)(a, Float64(b))
@inline (-)(a::Float32, b::Double{Float64,E}) where E<:Emphasis = (-)(Float64(a), b)
@inline (-)(a::Double{Float32,E}, b::Float64) where E<:Emphasis = (-)(Double(E, Float64(a.hi), Float64(a.lo)), b)
@inline (-)(a::Float64, b::Double{Float32,E}) where E<:Emphasis = (-)(a, Double(E, Float64(b.hi), Float64(b.lo)))

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
# reworked for subraction
function (-)(x::Double{T, E}, y::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_diff(x.hi, y.hi)
    thi, tlo = two_diff(x.lo, y.lo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return Double(E, hi, lo)
end

@inline (-)(a::Double{Float64,E}, b::Double{Float32,E}) where E<:Emphasis = (-)(a, Double(E, Float64(b.hi), Float64(b.lo)))
@inline (-)(a::Double{Float32,E}, b::Double{Float64,E}) where E<:Emphasis = (-)(Double(E, Float64(a.hi), Float64(b.hi)), b)

function sub_hilofl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_diff(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

# Algorithm 6 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
# reworked for subraction
function sub_hilohilo(xhi::T, xlo::T, yhi::T, ylo::T) where T<:SysFloat
    hi, lo = two_diff(xhi, yhi)
    thi, tlo = two_diff(xlo, ylo)
    c = lo + thi
    hi, lo = two_sum_hilo(hi, c)
    c = tlo + lo
    hi, lo = two_sum_hilo(hi, c)
    return hi, lo
end

# Algorithm 9 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (*)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b)
    lo += a.lo * b
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end
@inline (*)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = b * a

function prod_hilofl(ahi, alo, b)
    hi, lo = two_prod(a.hi, b)
    lo += a.lo * b
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end    

#=
theoretical relerr <= 5*(u^2)
experimental relerr ldexp(3.936,-106) == ldexp(1.968, -107)
=#

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function prod_hilohilo(xhi::T, xlo::T, yhi::T, ylo::T) where T<:SysFloat
    hi, lo = two_prod(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t)
    return hi, lo
end

# Algorithm 12 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (*)(x::Double{T,E}, y::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(x.hi, y.hi)
    t = x.lo * y.lo
    t = fma(x.hi, y.lo, t)
    t = fma(x.lo, y.hi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t)
    return Double(E, hi, lo)
end

@inline (*)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a * Float64(b)
@inline (*)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b * Float64(a)
(*)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a * promote_type(T,S)(b)
(*)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b * promote_type(T,S)(a)
(*)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a * Double(E, b)
(*)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b * Double(E, a)

function (/)(::T, b::Double{T,Performance}) where {T<:SysFloat}
    hi1 = a / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi1)
    xhi, xlo = two_sum(a, -hi)
    xlo -= lo
    hi2 = (xhi + xlo) / b.hi
    hi, lo = two_sum(hi1, hi2)
    return Double(hi, lo)
end

function (/)(a::Double{T,Performance}, b::T) where {T<:SysFloat}
    hi1 = a.hi / b
    hi, lo = prod_hilofl(a.hi, a.lo, hi1)
    xhi, xlo = two_sum(b, -hi)
    xlo -= lo
    hi2 = (xhi + xlo) / a.hi
    hi, lo = two_sum(hi1, hi2)
    return Double(hi, lo)
end

function (/)(a::Double{T,Performance}, b::Double{T,Performance}) where {T<:SysFloat}
    hi1 = a.hi / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi1)
    xhi, xlo = two_sum(a.hi, -hi)
    xlo -= lo
    xlo += a.lo
    hi2 = (xhi + xlo) / b.hi
    hi, lo = two_sum(hi1, hi2)
    return Double(hi, lo)
end

# Algorithm 15 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (/)(x::Double{T,Accuracy}, y::T) where {T<:SysFloat}
    hi = x.hi / y
    phi, plo = two_prod(hi, y)
    dhi = x.hi - phi
    dlo = x.lo - plo
    d = dhi + dlo
    lo = d / y
    hi, lo = two_sum(hi, lo)
    return Double(hi, lo)
end

@inline (/)(a::T, b::Double{T,Accuracy}) where {T<:SysFloat} = (/)(Double(Accuracy, a), b)

# Algorithm 18 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (/)(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:SysFloat}
    hi = x.hi / y.hi
    rhi = fma(-y.hi, hi, one(T))
    rlo = -y.lo * hi
    rhi, rlo = two_sum_hilo(rhi, rlo)
    rhi, rlo = prod_hilofl(rhi, rlo, hi)
    rhi, rlo = add_hilofl(rhi, rlo, hi)
    hi, lo = prod_hilohilo(x.hi, x.lo, rhi, rlo)
    return Double(hi, lo)
end

@inline (/)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a / Float64(b)
@inline (/)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b / Float64(a)
(/)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a / promote_type(T,S)(b)
(/)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b / promote_type(T,S)(a)
(/)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a / Double(E, b)
(/)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b / Double(E, a)
