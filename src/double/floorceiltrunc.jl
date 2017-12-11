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

function fld(x::Double{T,E}, y::T) where {T,E}y
    z = x / y
    return floor(z)
end

function fld(x::Double{T,E}, Double{T,E}::T) where {T,E}
    z = x / y
    return floor(z)
end

function cld(x::Double{T,E}, y::T) where {T,E}
    z = x / y
    return ceil(z)
end

function cld(x::Double{T,E}, Double{T,E}::T) where {T,E}
    z = x / y
    return trunc(z)
end

function tld(x::Double{T,E}, y::T) where {T,E}
    z = x / y
    return trunc(z)
end


