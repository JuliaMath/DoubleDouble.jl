using DoubleDouble

n = 1_000_000
X = 64*rand(n)
Y = 64*rand(n)

Zbig = Array(Float64,n)
Zdouble = Array(Float64,n)

function bigrem!(X,Y,Z)
    for i = 1:length(Z)
        Z[i] = float64(rem(big(X[i])*big(Y[i]),1.0))
    end
end

function doublerem!(X,Y,Z)
    for i = 1:length(Z)
        Z[i] = float64(rem(Single(X[i])*Single(Y[i]),1.0))
    end
end


bigrem!(X,Y,Zbig)
doublerem!(X,Y,Zdouble)

X = 64*rand(n)
Y = 64*rand(n)

@time bigrem!(X,Y,Zbig)
@time doublerem!(X,Y,Zdouble)
@assert Zbig == Zdouble
