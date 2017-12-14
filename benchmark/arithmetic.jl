using BenchmarkTools
using DoubleDouble

x = Double(rand()) * Double(rand())
y = convert(Double{Float64, Performance}, x)
for T in [:Float32, :Float64]
    @eval begin
        x = Double(rand($T)) * Double(rand($T))
        y = convert(Double{$T, Performance}, x)
        #
        println("$($T): Accuracy")
        println("+")
        @btime +($x, $x)
        println("-")
        @btime -($x, $x)
        println("*")
        @btime *($x, $x)
        println("/")
        @btime /($x, $x)

        println("$($T): Performance")
        println("+")
        @btime +($y, $y)
        println("-")
        @btime -($y, $y)
        println("*")
        @btime *($y, $y)
        println("/")
        @btime /($y, $y)
    end
end
