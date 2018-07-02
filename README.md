DoubleDouble.jl
===============

**Note: This package is no longer maintained. I suggest using [DoubleFloats.jl](https://github.com/JuliaMath/DoubleFloats.jl) instead.**

`DoubleDouble.jl` is a Julia package for performing extended-precision arithmetic using pairs of floating-point numbers. This is commonly known as "double-double" arithmetic, as the most common format is a pair of C-doubles (`Float64` in Julia), although `DoubleDouble.jl` will actually work for any floating-point type. Its aim is to provide accurate results without the overhead of `BigFloat` types.

The core routines are based on the ideas and algorithms of [Dekker (1971)][dekker1971].

Interface
---------
The main type is `Double`, with two floating-point fields: `hi`, storing the leading bits, and `lo` storing the remainder. `hi` is stored to full precision and rounded to nearest; hence, for any `Double` `x`, we have `abs(x.lo) <= 0.5 * eps(x.hi)`. Although these types can be created directly, the usual interface is the `Double` function:

```julia
julia> using DoubleDouble

julia> x = Double(pi)
Double{Float64}(3.141592653589793,1.2246467991473532e-16)

julia> eps(x.hi)
4.440892098500626e-16
```

The other type defined is `Single`, which is simply a wrapper for a
floating-point type, but whose results will be promoted to `Double`.

Examples
---------
### Exact products and remainders

By exploiting this property, we can compute exact products of floating point numbers.

```julia
julia> u, v = 64 * rand(), 64 * rand()
(15.59263373822506,39.07676672446341)

julia> w = Single(u) * Single(v)
Double{Float64}(609.3097112086186, -5.3107663829696295e-14)
```
Note that the product of two `Single`s is a `Double`: the `hi` element of this
double is equal to the usual rounded product, and the `lo` element contains the exact
difference between the exact value and the rounded.

This can be used to get an accurate remainder
```julia
julia> r = rem(w, 1.0)
Double{Float64}(0.309711208618584, 1.6507898617445858e-17)

julia> Float64(r)
0.309711208618584
```

This is much more accurate than taking ordinary products, and gives the same answer as using `BigFloat`s:
```julia
julia> rem(u*v, 1.0)
0.3097112086186371

julia> Float64(rem(big(u) * big(v), 1.0))
0.309711208618584
```
However, since the `DoubleDouble` version is carried out using ordinary floating-point operations, it is of the order of 1000x faster than the `BigFloat` version.

### Correct rounding with non-exact floats

If a number cannot be exactly represented by a floating-point number, it may be rounded incorrectly when used later, e.g.
```julia
julia> pi * 0.1
0.3141592653589793

julia> Float64(big(pi) * 0.1)
0.31415926535897937
```
We can also do this computation using `Double`s (note that the promotion rules mean that only one needs to be specified):
```julia
julia> Float64(Double(pi) * 0.1)
0.31415926535897937

julia> Float64(pi * Single(0.1))
0.31415926535897937
```

### Emulated FMA

The [fused multiply-add (FMA)](http://en.wikipedia.org/wiki/Multiply%E2%80%93accumulate_operation) operation is an intrinsic floating-point
operation that allows the evaluation of `a * b + c`, with rounding occurring only
at the last step. This operation is unavailable on 32-bit x86 architecture, and available
only on the most recent x86_64 chips, but can be emulated via double-double arithmetic:

```julia
julia> 0.1 * 0.1 + 0.1
0.11000000000000001

julia> Float64(big(0.1) * 0.1 + 0.1)
0.11

julia> Base.fma(a::Float64,b::Float64,c::Float64) = Float64(Single(a) * Single(b) + Single(c))
fma (generic function with 1 method)

julia> fma(0.1, 0.1, 0.1)
0.11
```

[dekker1971]: http://link.springer.com/article/10.1007%2FBF01397083  "T.J. Dekker (1971) 'A floating-point technique for extending the available precision', Numerische Mathematik, Volume 18, Issue 3, pp 224-242"
