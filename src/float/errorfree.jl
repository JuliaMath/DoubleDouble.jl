#=
    All functions present in this file should be errorfree tranformations.

    Nearly errorfree transformations (`one_inv`, `one_sqrt`, `two_divide`, ..)
      are collected in "errorbest.jl".
=#


"""
    two_sum_hilo(a, b)

*unchecked* requirement `|a| ≥ |b|`

Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function two_sum_hilo(a::T, b::T) where T<:SysFloat
    ab = a + b
    e = b - (ab - a)
    return ab, e
end

@inline function two_sum_inorder(a::T, b::T) where T<:SysFloat
    ab = a + b
    p  = ab - a
    e  = b - p
    return ab, e
end



"""
    two_sum(a, b)

Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function two_sum(a::T, b::T) where T<:SysFloat
    s = a + b
    v = s - a
    e = (a - (s - v)) + (b - v)
    return s, e
end

"""
    two_diff_hilo(a, b)
    
*unchecked* requirement `|a| ≥ |b|`

Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function two_diff_hilo(a::T, b::T) where T<:SysFloat
    s = a - b
    e = (a - s) - b
    s, e
end

"""
    two_diff(a, b)

Computes `s = fl(a-b)` and `e = err(a-b)`.
"""
@inline function two_diff(a::T, b::T) where T<:SysFloat
    s = a - b
    v = s - a
    e = (a - (s - v)) - (b + v)

    s, e
end

"""
    two_prod(a, b)

Computes `s = fl(a*b)` and `e = err(a*b)`.
"""
@inline function two_prod(a::T, b::T) where T<:SysFloat
    p = a * b
    e = fma(a, b, -p)
    p, e
end

"""
    one_square(a)

Computes `s = fl(a*a)` and `e = err(a*a)`.
"""
@inline function one_square(a::T) where T<:SysFloat
    p = a * a
    e = fma(a, a, -p)
    p, e
end

"""
    one_cube(a)

Computes `s = fl(a*a*a)` and `e = err(a*a*a)`.
"""
@inline function one_cube(a::T) where T<:SysFloat
    hi, lo = one_square(a)
    hihi, hilo = two_prod(hi, a)
    lohi, lolo = two_prod(lo, a)
    hilo, lohi = two_sum_hilo(hilo, lohi)
    hi, lo = two_sum_hilo(hihi, hilo)
    lo += lohi + lolo
    return hi, lo
end


"""
    three_sum_hilo(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`

Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function three_sum_hilo(a::T,b::T,c::T) where T<:SysFloat
    s, t = two_sum_hilo(b, c)
    x, u = two_sum_hilo(a, s)
    y, z = two_sum_hilo(u, t)
    x, y = two_sum_hilo(x, y)
    return x, y, z
end

"""
    three_sum(a, b, c)
    
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function three_sum(a::T,b::T,c::T) where T<: SysFloat
    s, t = two_sum(b, c)
    x, u = two_sum(a, s)
    y, z = two_sum(u, t)
    x, y = two_sum_hilo(x, y)
    return x, y, z
end

"""
    three_diff_hilo(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`

Computes `s = fl(a-b-c)` and `e1 = err(a-b-c), e2 = err(e1)`.
"""
function three_diff_hilo(a::T,b::T,c::T) where T<:SysFloat
    s, t = two_diff_hilo(-b, c)
    x, u = two_sum_hilo(a, s)
    y, z = two_sum_hilo(u, t)
    x, y = two_sum_hilo(x, y)
    return x, y, z
end

"""
    three_diff(a, b, c)
    
Computes `s = fl(a-b-c)` and `e1 = err(a-b-c), e2 = err(e1)`.
"""
function three_diff(a::T,b::T,c::T) where T<: SysFloat
    s, t = two_diff(-b, c)
    x, u = two_sum(a, s)
    y, z = two_sum(u, t)
    x, y = two_sum_hilo(x, y)
    return x, y, z
end

#= !!FIXME!!
"""
    three_prod(a, b, c)
    
Computes `s = fl(a*b*c)` and `e1 = err(a*b*c), e2 = err(e1)`.
"""
function three_prod(a::T, b::T, c::T) where T<:SysFloat
    p, e = two_prod(a, b)
    x, p = two_prod(p, c)
    y, z = two_prod(e, c)
    return x, y, z
end
=#


"""
    four_sum(a, b, c, d)
    
Computes `s = fl(a+b+c+d)` and `e1, e2, e3 = err(a+b+c+d)`.
"""
function four_sum(a::T,b::T,c::T,d::T) where T<: SysFloat

    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    a,  t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    b,  t2 = two_sum(t0, t3)
    c,  d  = two_sum(t1, t2)

    return a, b, c, d
end
