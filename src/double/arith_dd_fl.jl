import Base: (+), (-), (*), (/), inv #square, inv, div, rem, cld, fld, mod, divrem, fldmod, sqrt,

function (+)(a::Double{T,E}, b::T) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_sum(a.hi, b)
    lo += a.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double{T,E}(hi, lo)
end

function (+)(a::T, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_sum(a, b.hi)
    lo += b.lo
    hi, lo = two_sum_hilo(hi, lo)

    return Double{T,E}(hi, lo)
end

@inline (+)(a::Double{T,E}, b::S) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = a + promote_type(T,S)(b)
@inline (+)(a::S, b::Double{T,E}) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = promote_type(T,S)(a) + b
function add_dd_fl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_sum(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

function (-)(a::Double{T,E}, b::T) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_diff(a.hi, b)
    lo += a.lo
    hi, l\o = two_sum_hilo(hi, lo)
    return Double{T,E}(hi, lo)
end

function (-)(a::T, b::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    hi, lo = two_diff(a, b.hi)
    lo += b.lo
    hi, lo = two_sum_hilo(hi, lo)
    return Double{T,E}(hi, lo)
end

@inline (-)(a::Double{T,E}, b::S) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = a - promote_type(T,S)(b)
@inline (-)(a::S, b::Double{T,E}) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = promote_type(T,S)(a) - b
                    
function sub_dd_fl(ahi::T, alo::T, b::T) where T<:SysFloat
    hi, lo = two_diff(ahi, b)
    lo += alo
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end

# Algorithm 9 from Tight and rigourous error bounds for basic building blocks of double-word arithmetic
function (*)(a::Double{T,E}, b::T) where {T<:SysFloat,E<:Emphasis}
    hi, lo = two_prod(a.hi, b)
    lo += a.lo * b
    hi, lo = two_sum_hilo(hi, lo)

    return Double{T,E}(hi, lo)
end
@inline (*)(a::T, b::Double{T,E}) where {T<:SysFloat,E<:Emphasis} = b * a

function prod_dd_fl(ahi, alo, b)
    hi, lo = two_prod(ahi, b)
    lo += alo * b
    hi, lo = two_sum_hilo(hi, lo)
    return hi, lo
end    

@inline (*)(a::Double{T,E}, b::S) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = a * promote_type(T,S)(b)
@inline (*)(a::S, b::Double{T,E}) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = promote_type(T,S)(a) * b

@inline (*)(a::Double{F1,E}, b::Double{F2,E}) where {E<:Emphasis, F1<:SysFloat, F2<:SysFloat} = (*)(E, a, b)

function (/)(::T, b::Double{T,Performance}) where {T<:SysFloat}
    hi1 = a / b.hi
    hi, lo = prod_dd_fl(b.hi, b.lo, hi1)
    xhi, xlo = two_sum(a, -hi)
    xlo -= lo
    hi2 = (xhi + xlo) / b.hi
    hi, lo = two_sum(hi1, hi2)
    return Double{T,Performance}(hi, lo)
end

function (/)(a::Double{T,Performance}, b::T) where {T<:SysFloat}
    hi1 = a.hi / b
    hi, lo = prod_dd_fl(a.hi, a.lo, hi1)
    xhi, xlo = two_sum(b, -hi)
    xlo -= lo
    hi2 = (xhi + xlo) / a.hi
    hi, lo = two_sum(hi1, hi2)
    return Double{T,Performance}(hi, lo)
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
    return Double{T,Accuracy}(hi, lo)
end

@inline (/)(a::T, b::Double{T,Accuracy}) where {T<:SysFloat} = (/)(Double(Accuracy, a), b)

@inline (/)(a::Double{T,E}, b::S) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = a / promote_type(T,S)(b)
@inline (/)(a::S, b::Double{T,E}) where {S<:SysFloat,T<:SysFloat,E<:Emphasis}  = promote_type(T,S)(a) / b
