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

function (+)(a::Double{T, E}, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hihi, hilo = two_sum(a.hi, b.hi)
    hi, lo = two_sum(a.lo, b.lo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)

    return Double(E, hi, lo)
end

@inline (+)(a::Double{Float64,E}, b::Double{Float32,E}) where E<:Emphasis = (+)(a, Double(E, Float64(b.hi), Float64(b.lo)))
@inline (+)(a::Double{Float32,E}, b::Double{Float64,E}) where E<:Emphasis = (+)(Double(E, Float64(a.hi), Float64(b.hi)), b)

function (+)(::Type{E}, ahi::T, alo::T, bhi::T, blo::T) where  {T<:SysFloat, E<:Emphasis}
    hihi, hilo = two_sum(ahi, bhi)
    hi, lo = two_sum(alo, blo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)

    return Double(E, hi, lo)
end

function add_hilofl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_sum(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

function add_hilohilo(ahi::T, alo::T, bhi::T, blo::T) where T<:SysFloat
    hihi, hilo = two_sum(ahi, bhi)
    hi, lo = two_sum(alo, blo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)
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

function (-)(a::Double{T, E}, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hihi, hilo = two_diff(a.hi, b.hi)
    hi, lo = two_diff(a.lo, b.lo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)

    return Double(E, hi, lo)
end

@inline (-)(a::Double{Float64,E}, b::Double{Float32,E}) where E<:Emphasis = (-)(a, Double(E, Float64(b.hi), Float64(b.lo)))
@inline (-)(a::Double{Float32,E}, b::Double{Float64,E}) where E<:Emphasis = (-)(Double(E, Float64(a.hi), Float64(b.hi)), b)

function (-)(::Type{E}, ahi::T, alo::T, bhi::T, blo::T) where  {T<:SysFloat, E<:Emphasis}
    hihi, hilo = two_sum(ahi, bhi)
    hi, lo = two_sum(alo, blo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)

    return Double(E, hi, lo)
end

function sub_hilofl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_diff(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

function sub_hilohilo(ahi::T, alo::T, bhi::T, blo::T) where T<:SysFloat
    hihi, hilo = two_diff(ahi, bhi)
    hi, lo = two_diff(alo, blo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)
    return hi, lo
end


function (*)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b)
    lo += a.lo * b
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end
@inline (*)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = b * a

#=
theoretical relerr <= 5*(u^2)
experimental relerr ldexp(3.936,-106) == ldexp(1.968, -107)
=#

function prod_hilohilo(xhi::T, xlo::T, yhi::T, ylo::T) where T<:SysFloat
    hi, lo = two_prod(xhi, yhi)
    t = xlo * ylo
    t = fma(xhi, ylo, t)
    t = fma(xlo, yhi, t)
    t = lo + t
    hi, lo = two_sum_hilo(hi, t0)
    return hi, lo
end

(*)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} =
    Double(E, dd_prod(a.hi, a.lo, b.hi, b.lo))
    
function (*)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b.hi)
    lo += a.hi*b.lo + a.lo*b.hi
    hi, lo = two_sum_hilo(hi, lo)

    return Double(E, hi, lo)
end

@inline (*)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a * Float64(b)
@inline (*)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b * Float64(a)
(*)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a * promote_type(T,S)(b)
(*)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b * promote_type(T,S)(a)
(*)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a * Double(E, b)
(*)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b * Double(E, a)

function prod_hilofl(ahi::T, alo::T, b::T) where {T<:SysFloat}
    hi, lo = two_prod(ahi, b)
    lo += alo*b
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

function (/)(a::T, b::Double{T,Performance}) where {T<:SysFloat}
    hi = a / b.hi
    hi2, lo2 =  b * hi
    lo2 = two_prod(a.hi, b)
    hi2, hi  = two_diff(a, hi2)
    hi -= lo2
    lo = (hi2 + hi) / b.hi
    hi, lo = two_sum(hi, lo)

    return Double(Performance, hi, lo)
end
@inline (/)(a::Double{T,Performance}, b::T) where {T<:SysFloat} = (/)(a, Double(Performance, b))

function (/)(a::Double{T,Performance}, b::Double{T,Performance}) where {T<:SysFloat}
    hi = a.hi / b.hi
    hi2, lo2 =  b * hi
    hi2, lo = two_diff(a.hi, hi2)
    lo -= lo2
    lo += a.hi
    lo = (hi3 + lo) / b.hi
    hi, lo = two_sum(hi, lo)
    return Double(Performance, hi, lo)
end

function (/)(a::T, b::Double{T,Accuracy}) where {T<:SysFloat}
    hi1 = a / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi1)
    xhi, xlo = add_hilofl(-hi, -lo, a)
    hi2 = xhi / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi2)
    xhi, xlo = sub_hilohilo(xhi, xlo, hi, lo)
    hi3 = xhi / b.hi
    hi, lo = two_sum_hilo(hi1, hi2)
    hi, lo = sum_hilofl(hi1, hi2, hi3)
    return Double(hi, lo)
end    

@inline (/)(a::Double{T,Accuracy}, b::T) where {T<:SysFloat} = (/)(a, Double(Accuracy, b))

function (/)(a::Double{T,Accuracy}, b::Double{T,Accuracy}) where {T<:SysFloat}
    hi1 = a.hi / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi1)
    xhi, xlo = sub_hilohilo(a.hi, a.lo, hi, lo)
    hi2 = xhi / b.hi
    hi, lo = prod_hilofl(b.hi, b.lo, hi2)
    xhi, xlo = sub_hilohilo(a.hi, a.lo, hi, lo)
    hi3 = xhi / b.hi
    hi, lo = two_sum_hilo(hi1, hi2)
    hi, lo = add_hilofl(hi, lo, hi3)
    return Double(hi, lo)
end

@inline (/)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a / Float64(b)
@inline (/)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b / Float64(a)
(/)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a / promote_type(T,S)(b)
(/)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b / promote_type(T,S)(a)
(/)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a / Double(E, b)
(/)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b / Double(E, a)
