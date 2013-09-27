using TwoFloat

n = 100_000
X = 64*rand(n)
Y = 64*rand(n)

Zbig = Array(Float64,n)
Ztwo = Array(Float64,n)

function bigrem!(X,Y,Z)
    for i = 1:length(Z)
        Z[i] = float64(rem(big(X[i])*big(Y[i]),1.0))
    end
end

function tworem!(X,Y,Z)
    for i = 1:length(Z)
        Z[i] = float64(rem(split(X[i])*split(Y[i]),1.0))
    end
end


bigrem!(X,Y,Zbig)
tworem!(X,Y,Ztwo)

X = 64*rand(n)
Y = 64*rand(n)

@time bigrem!(X,Y,Zbig)
@time tworem!(X,Y,Ztwo)
@assert Zbig == Ztwo
