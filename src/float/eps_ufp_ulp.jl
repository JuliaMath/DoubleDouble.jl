
half(::Type{Float64}) = 0.5
half(::Type{Float32}) = 0.5f0
half(::Type{Float16}) = Float16(0.5)

"""
    eps_ieee(x)
    relative rounding error unit
"""    
eps_ieee(::Type{Float64}) = Float64(1/Int64(2)^53)
eps_ieee(::Type{Float32}) = Float32(1/2^24)
eps_ieee(::Type{Float16}) = Float16(1/2^11)

"""
    eps_ieee(x)
    relative rounding error unit
    
eps_ieee(x) = 0.5 * eps(x)
"""
function eps_ieee(x::T) where T<:AbstractFloat
    return half(T)*eps(x)
end


"""
    eta(T)
    
smallest unnormalized floating point number
"""
eta(::Type{Float64}) = 2.0^(-1074)
eta(::Type{Float32}) = 2.0f0^(-139)
eta(::Type{Float16}) = Float16(2.0f0^(-24))


"""
    ufp(x)
    unit first place
    
ufp(x) = 2.0^floor(log2(abs(x)))
"""
@inline function ufp(x::T) where T<:AbstractFloat
    return iszero(x) ? x : ldexp(0.5, frexp(x)[2])
end

ufp(::Type{Float32}) = ldexp(0.5f0, 1)
ufp(::Type{Float64}) = ldexp(0.5, 1)

"""
   ulp(x)
   unit last place
   
ulp(x) = 2.0 * eps_ieee(1.0) * ufp(x)
"""
@inline function ulp(x::T) where T<:AbstractFloat
    return iszero(x) ? x : eps(T) * ldexp(0.5, frexp(x)[2])
end

ulp(::Type{Float32}) = ldexp(0.5f0, -22)
ulp(::Type{Float64}) = ldexp(0.5, -51)

"""
   slp(x)
   shift over last place [slip past last place]

where s,e = frexp(x)    
slp(x) = e + typeof(x)==Float64 ? -53-1 : -24-1    
slp(x) provides the correct power of two with respect to the least significant bit
"""
@inline function slp(x::Float32)
    return frexp(x)[2] - 25
end
@inline function slp(x::Float64)
    return frexp(x)[2] - 54
end
