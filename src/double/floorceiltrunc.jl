import Base: floor, ciel, trunc, fld, cld

function floor(x::Double{T,E}) where {T,E}
    (notfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              Double(E, hi(x)-one(T), zero(T))
        else
              Double(E, hi(x), zero(T))
        end
    else
        Double(e, floor(hi(x)), zero(T))
    end
end

function ceil(x::Double{T,E}) where {T,E}
    (notfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              Double(E, hi(x), zero(T))
        else
              Double(E, hi(x)+one(T), zero(T))
        end
    else
        Double(e, ceil(hi(x)), zero(T))
    end
end

function trunc(x::Double{T,E}) where {T,E}
    (notfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              signbit(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, hi(x)-one(T), zero(T))
        else
              signbit(hi(x)) ? Double(E, hi(x)+one(T), zero(T)) : Double(E, hi(x), zero(T))
        end
    else
        signbit(hi(x)) ? Double(e, ceil(hi(x)), zero(T)) :  Double(e, floor(hi(x)), zero(T))
    end
end

"""
    tld(x, y)

Truncate the result of x/y.
""" tld

for (F,G) in ((:fld, :floor), (:cld, :ceil), (:tld, :trunc))
    @eval begin
        function $F(x::Double{T,E}, y::T) where {T<:SysFloat, E}
            z = x / y
            return $G(z)
        end
        function $F(x::T, y::Double{T,E}) where {T<:SysFloat, E}
            z = x / y
            return $G(z)
        end
        function $F(x::Double{T,E}, y::Double{T,E}) where {T<:SysFloat, E}
            z = x / y
            return $G(z)
        end
    end
end
