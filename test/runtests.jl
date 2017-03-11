
using DoubleDouble
using Base.Test


x = sqrt(2.0)
bx = big(x)
sx = Single(x)
dx = Double(x)

y = 0.1
by = big(y)
sy = Single(y)
dy = Double(y)

@test x == sx == dx
@test y == sy == dy

@test zero(Double{Float64}) == Double(0.0, 0.0)
@test one(Double{Float64}) == Double(1.0, 0.0)
@test zero(Double(0.0, 0.0)) == Double(0.0, 0.0)
@test one(Double(0.0, 0.0)) == Double(1.0, 0.0)

dxy = dx*dy
bxy = bx*by
@test sx*sy == dxy
@test x*y == Float64(dxy)
@test dxy == Double(bxy)

@test x+y == Float64(dx+dy)
@test dx+dy == Double(bx+by)

@test x-y == Float64(dx-dy)
@test dx-dy == Double(bx-by)

@test x/y == Float64(dx/dy)
@test dx/dy == Double(bx/by)

@test sqrt(y) == Float64(sqrt(dy))
@test sqrt(dy) == Double(sqrt(by))

#@test rem(dxy,1.0) == Double(rem(bxy,1.0))


## New
@test Double(pi) == Double{Float64}(3.141592653589793, 1.2246467991473532e-16)
@test Double(3.5) == Double{Float64}(3.5, 0.0)
@test Double(3.5) == Double{Float64}(3.5, 0.0)

a = Double(big"3.1")
@test a == Double(3.1, -8.881784197001253e-17)
@test BigFloat(a) == big"3.099999999999999999999999999999995069619342368676216176696466982586064542459781"

@test Single(3) === Single(3.0)
@test Double(3) === Double(3.0, 0.0)
@test Double(big(3)) === Double(3.0, 0.0)

@test convert(Single{Float64}, 1) === Single(1.0)
@test convert(Single{Float32}, 1) === Single(1.0f0)
@test convert(Double{Float64}, 1) === Double(1.0, 0.0)
@test convert(Double{Float32}, 1) === Double(1.0f0, 0.0f0)

@test Single{Float32}(3) === Single{Float32}(3.0f0)
@test Double{Float32}(3) === Double{Float32}(3.0f0, 0.0f0)
@test Single{Float32}(BigFloat(3)) === Single{Float32}(3.0f0)
@test Double{Float32}(BigFloat(3)) === Double{Float32}(3.0f0, 0.0f0)
