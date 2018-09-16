using DoubleDouble, ProgressMeter, Base.Test

# Compare precision in a manner sensitive to subnormals, which lose
# precision compared to widening.
function cmp_sn(w, hi, lo, slopbits=0)
    if !isfinite(hi)
        if abs(w) > realmax(typeof(hi))
            return isinf(hi) && sign(w) == sign(hi)
        end
        if isnan(w) && isnan(hi)
            return true
        end
        return w == hi
    end
    if abs(w) < subnormalmin(typeof(hi))
        return (hi == zero(hi) || abs(w - widen(hi)) < abs(w)) && lo == zero(hi)
    end
    # Compare w == hi + lo unless `lo` issubnormal
    z = widen(hi) + widen(lo)
    if !issubnormal(lo) && lo != 0
        if slopbits == 0
            return z == w
        end
        wr, zr = roundshift(w, slopbits), roundshift(z, slopbits)
        return max(wr-1, zero(wr)) <= zr <= wr+1
    end
    # round w to the same number of bits as z
    zu = asbits(z)
    wu = asbits(w)
    lastbit = false
    while zu > 0 && !isodd(zu)
        lastbit = isodd(wu)
        zu = zu >> 1
        wu = wu >> 1
    end
    return wu <= zu <= wu + lastbit
end

asbits(x) = reinterpret(Base.fpinttype(typeof(x)), x)

function roundshift(x, n)
    xu = asbits(x)
    lastbit = false
    for i = 1:n
        lastbit = isodd(xu)
        xu = xu >> 1
    end
    xu + lastbit
end

subnormalmin(::Type{T}) where T = reinterpret(T, Base.fpinttype(T)(1))

function Base.issubnormal(x::Float16)
    y = reinterpret(UInt16, x)
    (y & Base.exponent_mask(Float16) == 0) & (y & Base.significand_mask(Float16) != 0)
end

Base.iszero(x::Float16) = reinterpret(UInt16, x) & ~Base.sign_mask(Float16) == 0x0000

# Troublesome values
x = Float16(6.45e4)
y = Float16(2112.0)
d = Single(x) * Single(y)
@test cmp_sn(widen(x)*widen(y), d.hi, d.lo)

function pair16()
    @showprogress 1 "testing" for yu in 0x0000:0xffff
        for xu in 0x0000:0xffff
            x, y = reinterpret(Float16, xu), reinterpret(Float16, yu)
            try
                d = Single(x) * Single(y)
                @test cmp_sn(widen(x)*widen(y), d.hi, d.lo)
            catch
                @show x y
                rethrow()
            end
        end
    end
end

pair16()
