"""
    quick_two_sum(a, b)

Computes `s = fl(a+b)` and `e = err(a+b)`. Assumes `|a| ≥ |b|`.
"""
@inline function quick_two_sum(a::T, b::T) where T<:SysFloat
    s = a + b
    e = b - (s - a)
    return s, e
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
    quick_two_diff(a, b)
    
Computes `s = fl(a-b)` and `e = err(a-b)`.  Assumes `|a| ≥ |b|`.
"""
@inline function quick_two_diff(a::T, b::T) where T<:SysFloat
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
    two_square(a)

Computes `s = fl(a*a)` and `e = err(a*a)`.
"""
@inline function two_square(a::T) where T<:SysFloat
    p = a * a
    e = fma(a, a, -p)
    p, e
end
