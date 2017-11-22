import Base: signbit, sign, abs, (+) # (-), (*), (/), square, inv, div, rem, cld, fld, mod, divrem, fldmod, sqrt,

@inline signbit(a::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = signbit(a.hi)
@inline sign(a::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = sign(a.hi)
@inline abs(a::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = signbit(a) ? Double(E, -a.hi, -a.lo) : a

@inline function (-)(a::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    return Double(-a.hi, -a.lo)
end

function (+)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_sum(a.hi, b)
    lo += a.lo
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end


function (+)(::Type{E}, ahi::T, alo::T, b::T) where  {T<:SysFloat,E<:Emphasis}
    hi, lo = two_sum(ahi, b)
    lo += alo
    hi, lo = two_sum_sorted(hi, lo)
    
    return Double(E, hi, lo)
end
@inline (+)(a::T, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis} = (+)(E, b.hi, b.lo, a)

function (+)(::Type{E}, ahi::T, alo::T, bhi::T, blo::T) where {T<:SysFloat,E<:Emphasis}
    hihi, hilo = two_sum(ahi, bhi)
    hi, lo = two_sum(alo, blo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)
    
    return Double(E, hi, lo)
end
@inline (+)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = (+)(E, a.hi, a.lo, b.hi, b.lo)


function (+)(a::Double{T1,E}, b::T2) where {T1<:SysFloat,T2<:SysFloat,E<:Emphasis}
    if sizeof(T2) > sizeof(T1)
       Double(E, T2(a.hi), T2(a.lo)) + b
    else
       a + T1(b)
   end
end

(+)(a::T2, b::Double{T1,E}) where {T1<:SysFloat,T2<:SysFloat,E<:Emphasis} = b + a
@inline (+)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a + Float64(b)
@inline (+)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b + Float64(a)

(+)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a + promote_type(T,S)(b)
(+)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b + promote_type(T,S)(a)
(+)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a + Double(E, b)
(+)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b + Double(E, a)



function (-)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_diff(a.hi, b)
    lo += a.lo
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end

function (-)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_diff(a, b.hi)
    lo -= b.lo
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end

function (-)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hihi, hilo = two_diff(a.hi, b.hi)
    hi, lo = two_diff(a.lo, b.lo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)
    return Double(E, hi, lo)
end

@inline (-)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a - Float64(b)
@inline (-)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b - Float64(a)
(-)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a - promote_type(T,S)(b)
(-)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b - promote_type(T,S)(a)
(-)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a - Double(E, b)
(-)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b - Double(E, a)



function (*)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b)
    lo += a.lo * b
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end
@inline (*)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = b * a

function (*)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b.hi)
    lo += a.hi*b.lo + a.lo*b.hi
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end

@inline (*)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a * Float64(b)
@inline (*)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b *\ Float64(a)
(*)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a * promote_type(T,S)(b)
(*)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b * promote_type(T,S)(a)
(*)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a * Double(E, b)
(*)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b * Double(E, a)





function (/)(a::T, b::Double{T,Performance}) where {T<:SysFloat}
    hi = a / b.hi
    hi2, lo2 =  b * hi
    lo2 = two_prod(a.hi, b)
    hi2, hi  = two_diff(a, hi2)
    hi -= lo2
    lo = (hi2 + hi) / b.hi
    hi, lo = two_sum(hi, lo)

    return Double(E, hi, lo)
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
    return Double(E, hi, lo)
end




function (/)(a::T, b::Double{T,Accuracy}) where {T<:SysFloat}

    hi = a / b.hi
    hi2, lo2 =  -(b * hi)
    hi3, lo3 = Double(Accuracy, hi2, lo2) + a
    lo = hi3 / b.hi
    hi2, lo2 = b * lo
    hi3, lo3 = Double(Accuracy,hi3, lo3) - Double(Accuracy, hi2, lo2)
    lw = hi3 / b.hi
    hi, lo = two_sum_sorted(hi, lo)
    hi, lo = Double(Accuracy, hi, lo) + lo
    
    return Double(Accuracy, hi, lo)
end

@inline (/)(a::Double{T,Accuracy}, b::T) where {T<:SysFloat} = (/)(a, Double(Accuracy, b))

function (/)(a::Double{T,Accuracy}, b::Double{T,Accuracy}) where {T<:SysFloat}
    hi = a.hi / b.hi
    hi2, lo2 =  b * hi
    hi2, lo = two_diff(a.hi, hi2)
    lo -= lo2
    lo += a.hi
    lo = (hi3 + lo) / b.hi
    hi, lo = two_sum(hi, lo)
    return Double(E, hi, lo)
end


@inline (/)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a / Float64(b)
@inline (/)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b / Float64(a)
(/)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = a / promote_type(T,S)(b)
(/)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis}  = b / promote_type(T,S)(a)
(/)(a::Double{T,E}, b::R) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = a / Double(E, b)
(/)(a::R, b::Double{T,E}) where {R<:SysReal,T<:SysFloat,E<:Emphasis} = b / Double(E, a)

