const Zero64x2 = Double(zero(Float64), zero(Float64))
const Zero32x2 = Double(zero(Float32), zero(Float32))
const Zero16x2 = Double(zero(Float16), zero(Float16))
const FastZero64x2 = Double{Float64, Performance}(zero(Float64), zero(Float64))
const FastZero32x2 = Double{Float32, Performance}(zero(Float32), zero(Float32))
const FastZero16x2 = Double{Float16, Performance}(zero(Float16), zero(Float16))
const One64x2 = Double(one(Float64), zero(Float64))
const One32x2 = Double(one(Float32), zero(Float32))
const One16x2 = Double(one(Float16), zero(Float16))
const FastOne64x2 = Double{Float64, Performance}(one(Float64), zero(Float64))
const FastOne32x2 = Double{Float32, Performance}(one(Float32), zero(Float32))
const FastOne16x2 = Double{Float16, Performance}(one(Float16), zero(Float16))
const NaN64x2 = Double(NaN64, NaN64)
const NaN32x2 = Double(NaN32, NaN32)
const NaN16x2 = Double(NaN16, NaN16)
const FastNaN64x2 = Double{Float64, Performance}(NaN64, NaN64)
const FastNaN32x2 = Double{Float32, Performance}(NaN32, NaN32)
const FastNaN16x2 = Double{Float16, Performance}(NaN16, NaN16)
const Inf64x2 = Double(Inf64, zero(Float64))
const Inf32x2 = Double(Inf32, zero(Float32))
const Inf16x2 = Double(Inf16, zero(Float16))
const FastInf64x2 = Double{Float64, Performance}(Inf64, zero(Float64))
const FastInf32x2 = Double{Float32, Performance}(Inf32, zero(Float32))
const FastInf16x2 = Double{Float16, Performance}(Inf16, zero(Float16))
