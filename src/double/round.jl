import Base: round
        
function round(x::Double{T,E}) where {T,E}
    (notfinite(x) || isinteger(x)) && return x
    result =  isinteger(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, round(hi(x)), zero(T))
    return result
end

@inline function round(::Type{Double{T,E}}, x::Double{T,E}, ::Type{RoundNearest}) where {T<:SysFloat, E<:Emphasis}
    return x
end
@inline function round(::Type{Double{T,E}}, x::Double{T,E}, ::Type{RoundUp}) where {T<:SysFloat, E<:Emphasis}
    return Double(E, hi(x), nextfloat(lo(x)))
end
@inline function round(::Type{Double{T,E}}, x::Double{T,E}, ::Type{RoundDown}) where {T<:SysFloat, E<:Emphasis}
    return Double(E, hi(x), prevfloat(lo(x)))
end
@inline function round(::Type{Double{T,E}}, x::Double{T,E}, ::Type{RoundToZero}) where {T<:SysFloat, E<:Emphasis}
    return signbit(x) ? round(Double{T,E}, x, RoundUp) : round(Double{T,E}, x, RoundDown)
end

@inline function round(x::Double{T,E}, ::Type{R}) where {R<:RoundingMode, T, E}
    return round(Double{T,E}, x, R)
end

for T in (:Float64, :Float32, :Float16)
    @eval begin
        @inline round(::Type{$T}, x::$T, ::Type{RoundNearest}) = x
        @inline round(::Type{$T}, x::$T, ::Type{RoundUp}) = nextfloat(x)
        @inline round(::Type{$T}, x::$T, ::Type{RoundDown}) = prevfloat(x)
        @inline round(::Type{$T}, x::$T, ::Type{RoundToZero}) = signbit(x) ? round($T, x, RoundUp) : round($T, x, RoundDown)
        @inline round(::Type{Double{$T,E}}, x::Double{$T,E}, ::Type{RoundNearest}) where {E} = x
        @inline round(::Type{Double{$T,E}}, x::Double{$T,E}, ::Type{RoundUp}) where {E} = Double(E, hi(x), nextfloat(lo(x)))
        @inline round(::Type{Double{$T,E}}, x::Double{$T,E}, ::Type{RoundDown}) where {E} = Double(E, hi(x), prevfloat(lo(x)))
        @inline round(::Type{Double{$T,E}}, x::Double{$T,E}, ::Type{RoundToZero}) where {E} = signbit(x) ? round(Double{$T,E}, x, RoundUp) : round(Double{$T,E}, x, RoundDown)
    end            
end

for M in (:RoundNearest, :RoundNearestTiesAway, :RoundNearestTiesUp, :RoundUp, :RoundDown, :RoundToZero)
    @eval begin
        round(x::T, $M) where T<:SysFloat = round(T, x, $M)
    end
end        

for M in (:RoundNearest, :RoundNearestTiesAway, :RoundNearestTiesUp, :RoundUp, :RoundDown, :RoundToZero)
    @eval begin
        function round(::Type{Double{T,E}}, x::Double{T,E}, $M) where {T,E}
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
