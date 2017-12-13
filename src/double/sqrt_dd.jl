#=
     for a in [1e-15..1e18]
      relerr ~1.3e-32  (106 bits)
=#
#=
function sqrt(a::DD)
    if hi(a) <= zero(Float64)
       if hi(a) == zero(Float64)
           return zero(DD)
       else#=
     for a in [1e-18..1e18]
      relerr ~1.3e-32  (106 bits)
=#
function sqrt_midrange(a::Double{T,E}) where {T,E}
    iszero(a) && return a
    signbit(a) && throw(DomainError("attempting sqrt(negative value)"))
    if !(1.0e-18 <= hi(a) <= 1.0e18)
       return hi(a) < one(T) ? sqrt_small(a) : sqrt_large(a)
    end
     
    if (hi(a) < 1.0e-7)  # -log2(1.0e-7) < (1/2) Float64 significand bits
        return one(Double{T,E}) / sqrt(one(Double{T,E})/a)
    end

    one1 = one(Double{T,E})
    # initial approximation to 1/sqrt(a)
    res = Double(E, one(T)/sqrt(hi(a)), zero(T))

    res += divby2(res * (one1 - (a*(res*res))) )
    res += divby2(res * (one1 - (a*(res*res))) )
    res += divby2(res * (one1 - (a*(res*res))) )

    res = a*res
    res += a/res
    res = divby2(res)
    
    return res
end

#=
   these consts are used when searching for an fldxp exponent
   the whole_square_pow2 values are used to bound the absval of the frexp pow2 exponent
   the half_square_pow2 values are used to rescale a scaled sqrt outome
   values are kept  as a tuple of Int16s, for faster finds 
=#   
const half_square_pow2  = ((Int16).([0, 1, 2,  8,  18,  32,  50,  72,  98,  128,  162,  200,  242,  288,  338,  392,  450,  512, 578])...,);
const whole_square_pow2 = ((Int16).([0, 2, 4,  16,  36,  64,  100,  144,  196,  256,  324,  400,  484,  576,  676,  784,  900,  1024, 1156])...,);

@inline function find_square_pow2_index(absint)
     idx = 1 
     while whole_square_pow2[idx] < absint
         idx += 1
     end
     return idx
end

# a < 1.0e-18
function sqrt_small(a::Double{T,E}) where {T,E}
    frhi, xphi, frlo, xplo = frexp(a)
    # xphi is < 0
    absxphi = -xphi
    idx = find_square_pow2_index(absxphi)
    whole_pow2 = whole_square_pow2[idx]
    half_pow2  = whole_pow2 >> 1
    xphi -= whole_pow2
    xplo -= whole_pow2
    dd = Double(E, ldexp(frhi, xphi - whole_pow2), ldexp(frlo, xplo - whole_pow2))
    sqrtdd = sqrt_midrange(dd)
    frhi, xphi, frlo, xplo = frexp(sqrtdd)
    xphi += half_pow2; xplo += half_pow2;
    dd = Double(E, ldexp(frhi, xphi), ldexp(frlo, xplo))
    return dd
end

# a > 1.0e+18
function sqrt_large(a::Double{T,E}) where {T,E}
end
