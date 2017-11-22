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

function (+)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_sum(a, b.hi)
    lo += b.lo
    hi, lo = two_sum_sorted(hi, lo)

    return Double(E, hi, lo)
end

function (+)(a::Double{T,E}, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis}
    hihi, hilo = two_sum(a.hi, b.hi)
    hi, lo = two_sum(a.lo, b.lo)
    hilo += hi
    hi = hihi + hilo
    hilo -= hi - hihi
    lo += hilo
    hi,lo = two_sum(hi, lo)
    return Double(E, hi, lo)
end

function (+)(a::Double{T1,E}, b::T2) where {T1<:SysFloat,T2<:SysFloat,E<:Emphasis}
    if sizeof(T2) > sizeof(T1)
       Double(E, T2(a.hi), T2(a.lo)) + b
    else
       a + T1(b)
   end
end

(+)(a::T2, b::Double{T1,E}) where {T1<:SysFloat,T2<:SysFloat,E<:Emphasis} = b + a
(+)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a + Float64(b)
(+)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b + Float64(a)
(+)(a::Double{Float64,E}, b::Float32) where {E<:Emphasis} = a + Float64(b)
(+)(a::Float32, b::Double{Float64,E}) where {E<:Emphasis} = b + Float64(a)
(+)(a::Double{T,E}, b::S) where {S<:Signed,T<:SysFloat,E<:Emphasis} = a + promote_type(T,S)(b)
(+)(a::S, b::Double{T,E}) where {S<:Signed,T<:SysFloat,E<:Emphasis} = b + promote_type(T,S)(a)
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

