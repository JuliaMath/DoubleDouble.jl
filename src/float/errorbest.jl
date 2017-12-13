#=
    All functions present in this file should be almost errorfree tranformations.
    They should provide results that are usually ±1ulp and always ±2ulp of exact.
    
    A few references are given at the end of this file.
    
    Actual errorfree transformations are collected in "errorfree.jl".
    They should provide results that are either exact or correctly rounded.
=#

"""
    one_inv(a)

Computes `s = fl(inv(a))` and `e = err(inv(a))`.
"""
function one_inv(b::T) where T<:SysFloat
    x = one(T) / b
    v = x * b
    w = fma(x, b, -v)
    y = (one(T) - v - w) / b
    return x, y
end

"""
    one_sqrt(a)

Computes `s = fl(sqrt(a))` and `e = err(sqrt(a))`.
"""
function one_sqrt(a::T) where T<:SysFloat
    x = sqrt(a)
    t = fma(x, -x, a)
    y = t / (x+x)
    return x, y
end

#=


function sqrt(x::Double{T,E}) where {T,E}
    r = inv(sqrt(x))
    h = divby2(x)
    t0 = fma(r, h*r, -0.5)
    r += r*t0 
    t0 = fma(r, h*r, -0.5)
    r += r*t0 
    e = fma(r, r, -a)
    return r, e
end
=#
"""
    two_div(a, b)

Computes `s = fl(a/b)` and `e = err(a/b)`.
"""
function two_div(a::T, b::T) where T<:SysFloat
    x = a / b
    v = x * b
    w = fma(x, b, -v)
    y = (a - v - w) / b
    return x, y
end


#=
references

"Concerning the division, the elementary rounding error is
generally not a floating point number, so it cannot be computed
exactly. Hence we cannot expect to obtain an error
free transformation for the divideision. ...
This means that the computed approximation is as good as
we can expect in the working precision."
-- http://perso.ens-lyon.fr/nicolas.louvet/LaLo05.pdf

While the sqrt algorithm is not strictly an errorfree transformation,
it is known to be reliable and is recommended for general use.
"Augmented precision square roots, 2-D norms and 
   discussion on correctly reounding sqrt(x^2 + y^2)"
by Nicolas Brisebarre, Mioara Joldes, Erik Martin-Dorel,
   Hean-Michel Muller, Peter Kornerup
=#
