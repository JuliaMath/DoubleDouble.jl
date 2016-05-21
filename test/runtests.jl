
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

dxy = dx*dy
bxy = bx*by
@test sx*sy == dxy
@test x*y == Float64(dxy)
@test dxy == double(bxy)

@test x+y == Float64(dx+dy)
@test dx+dy == double(bx+by)

@test x-y == Float64(dx-dy)
@test dx-dy == double(bx-by)

@test x/y == Float64(dx/dy)
@test dx/dy == double(bx/by)

@test sqrt(y) == Float64(sqrt(dy))
@test sqrt(dy) == double(sqrt(by))

#@test rem(dxy,1.0) == Double(rem(bxy,1.0))


## New
@test double(pi) == Double{Float64}(3.141592653589793, 1.2246467991473532e-16)
@test Double(3.5) == Double{Float64}(3.5, 0.0)
@test double(3.5) == Double{Float64}(3.5, 0.0)

a = double(big"3.1")
@test a == Double(3.1, -8.881784197001253e-17)
@test BigFloat(a) == big"3.099999999999999999999999999999995069619342368676216176696466982586064542459781"

@test double(3) == Double(3.0, 0.0)
@test double(big(3)) == Double(3.0, 0.0)
