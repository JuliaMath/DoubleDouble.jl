import Base: round

function round(x::Double{T,E}) where {T,E}
    (notfinite(x) || isinteger(x)) && return x
    result =  isinteger(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, round(hi(x)), zero(T))
    return result
end

for M in (:RoundNearest, :RoundNearestTiesAway, :RoundNearestTiesUp, :RoundUp, :RoundDown, :RoundToZero)
    @eval begin
        function round(::Type{Double{T,E}, x::Double{T,E}, $M) where {T,E}
            (notfinite(x) || isinteger(x)) && return x
            result =  isinteger(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, round(hi(x), $M), zero(T))
            return result
        end
        round(x::Double{T,E}, $M) where {T,E} = round(Double{T,E}, x, $M)
   end
end

"""
    rld(x, y)

Round the result of x/y.
""" rld

for (F,G) in ((:rld, :round),)
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
