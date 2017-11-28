pi2   = Double(Float64(pi)^2)
invpi = Double(inv(Float64(pi)))
invpi2 = invpi * invpi

pi2_plus_invpi2 = pi2 + invpi2
pi2_minus_invpi2 = pi2 - invpi2

@test (pi2_plus_invpi + invpi2) - invpi == pi2_plus_invpi2
@test (pi2_minus_invpi2 + invpi) - invpi == pi2_minus_invpi2
