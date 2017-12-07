half(Float16) = Float16(0.5)
half(Float32) = 0.5f0
half(Float64) = 0.5

"""
    eps_ieee(x)
    relative rounding error unit
"""    
eps_ieee(Float32) = 2.0f0^(-24)
eps_ieee(Float64) = 2.0^(-53)

"""
    eta(T)
    
smallest unnormalized floating point number
"""
eta(Float32) = 2.0f0^(-139)
eta(Float64) = 2.0^(-1074)

"""
    eps_ieee(x)
    relative rounding error unit
    
eps_ieee(x) = 0.5 * eps(x)
"""
function eps_ieee(x::T) where T<:AbstractFloat
    return half(T)*eps(x)
end

"""
    ufp(x)
    unit first place
    
ufp(x) = 2.0^floor(log2(abs(x)))
"""
@inline function ufp(x::T) where T<:AbstractFloat
    return iszero(x) : x : ldexp(0.5, frexp(x)[2])
end

"""
   ulp(x)
   unit last place
   
ulp(x) = 2.0 * eps_ieee(1.0) * ufp(x)
"""
@inline function ulp(x::T) where T<:AbstractFloat
    return iszero(x) ? x : eps(T) * ldexp(0.5, frexp(x)[2])
end

