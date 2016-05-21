
using DoubleDouble
using Base.Test

double(x::BigFloat) = convert(Double{Float64},x)

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

@test rem(dxy,1.0) == double(rem(bxy,1.0))
