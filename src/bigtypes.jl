#=
    minimum_bigfloat_precision(Double{T,E})
    
    This evaluates to the number of bits that BigFloats are to use (at minimum)
        when interoperating with, or interconverting with, Double{T,E} values.
    
    The number of bits explicitly stored in the significand of a Double{T,E}:
         significand_bits(Double{T,E}) = 2 * significand_bits(T)
     The number of significand bits used as working precision for BigFloats
         must exceed 2*significand_bits(Float64) to insure correct results.
     For correctly rounded results from the elementary functions for all Float64 values,
         working precision needs to be about 3.25 greater than sigificand_bits(Float64).
     We can surmise that the proportional increase for Doubles is similar,
         and use a slightly higher value to increase possible coverage.

     bigfloat_precision(Double{Float64,E}) == nextpow2( 7 * 64 ) == 256
=#

minimum_bigfloat_precision(::Type{Double{T,E}}) where {T<:SysFloat, E<:Emphasis} = 
    nextpow2(cld(7 * precision(T), 2))
    
bigfloat_precision(::Type{Double{T,E}}) where {T<:SysFloat, E<:Emphasis} =
    round(Int, 1.1minimum_bigfloat_precision(Double{T,E})

setprecision(BigFloat, bigfloat_precision(Double{Float64, Accuracy}))

function Base.convert(::Type{BigFloat}, x::T) where T<:SysFloat
    x_str = @sprintf "%a" x    # hexidecimal strings are stable in travel 
    result = parse(BigFloat, x_str)
    return result
end

Base.convert(::Type{T}, x::BigFloat) where T<:SysFloat = T(x)

function Base.convert(::Type{BigFloat}, x::T) where {T<:SysFloat}
    sf_str = @sprintf "%a" x    # hexidecimal strings are stable in travel 
    result = parse(BigFloat, sf_string)
    return result
end

function Base.convert(::Type{BigFloat}, x::Double{T,E})
    hi_bf = convert(BigFloat, hi(x))
    lo_bf = convert(BigFloat, lo(x))
    result = hi_bf + lo_bf
    return result
end

# BigInt

function Base.convert(::Type{BigInt}, x::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
    (!isinteger(lo(x)) || !isinteger(hi(x))) && throw(InexactError())
    hi_bi = convert(BigFloat, hi(x))
    lo_bi = convert(BigFloat, lo(x))
    result = hi_bi + lo_bi
    return result
end
    
function Base.convert(::Type{Double{T,E}}, x::BigInt) where {T<:SysFloat, E<:Emphasis}
    absx = abs(x)
    stype = signed(T)
    hi = convert(stype, x)
    lo = convert(stype, x-convert(BigInt, hi))
    result = Double(E, T(hi), T(lo))
    return result
end
