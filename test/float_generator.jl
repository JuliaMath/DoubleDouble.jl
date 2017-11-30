const SIGNBIT_32 = one(UInt32) << 31
const SIGNBIT_64 = one(UInt64) << 63
const MAX_POS_32 = reinterpret(UInt32, realmax(Float32))
const MAX_POS_64 = reinterpret(UInt64, realmax(Float64))
const MIN_POS_32 = zero(UInt32)
const MIN_POS_NORM_32 = one(UInt32) << (31-8)
const MIN_POS_EPS_32 = reinterpret(UInt32, eps(Float32))
const MIN_POS_64 = zero(UInt64)
const MIN_POS_NORM_64 = one(UInt64) << (63-11)
const MIN_POS_EPS_64 = reinterpret(UInt64, eps(Float64))
const MAX_NEG_32 = reinterpret(UInt32, realmax(Float32)) | SIGNBIT_32
const MAX_NEG_64 = reinterpret(UInt64, realmax(Float64)) | SIGNBIT_64
const MIN_NEG_32 = SIGNBIT_32
const MIN_NEG_64 = SIGNBIT_64
const MIN_NEG_NORM_32 = MIN_POS_NORM_32 | SIGNBIT_32
const MIN_NEG_NORM_64 = MIN_POS_NORM_64 | SIGNBIT_64
const MIN_NEG_EPS_32 = MIN_POS_EPS_32 | SIGNBIT_32
const MIN_NEG_EPS_64 = MIN_POS_EPS_64 | SIGNBIT_64

const POS_RANGE_32 = MIN_POS_32:MAX_POS_32
const POS_NORM_RANGE_32 = MIN_POS_NORM_32:MAX_POS_32
const POS_EPS_RANGE_32 = MIN_POS_EPS_32:MAX_POS_32
const NEG_RANGE_32 = MIN_NEG_32:MAX_NEG_32
const NEG_NORM_RANGE_32 = MIN_NEG_NORM_32:MAX_NEG_32
const NEG_EPS_RANGE_32 = MIN_NEG_EPS_32:MAX_NEG_32
const POS_RANGE_64 = MIN_POS_64:MAX_POS_64
const POS_NORM_RANGE_64 = MIN_POS_NORM_64:MAX_POS_64
const POS_EPS_RANGE_64 = MIN_POS_EPS_64:MAX_POS_64
const NEG_RANGE_64 = MIN_NEG_64:MAX_NEG_64
const NEG_NORM_RANGE_64 = MIN_NEG_NORM_64:MAX_NEG_64
const NEG_EPS_RANGE_64 = MIN_NEG_EPS_64:MAX_NEG_64

"""
    FloatIterator(::Type{<:Union{Float32, Float64}}; targetlength=10_000, positive=true, constraint=:machine_eps)

Create an iterator over all possible floating point numbers of the respective type.
* `targetlength` is the number of uniform samples.
* `positive` is whether positive or negative numbers should be sampled.
* `constraint` limits the number of possible floating points numbers. Possible values are
`:machine_eps` (no number smaller than machine epsilon), `:normalized` (only normalized numbers),
`:denormalized` (all numbers including denormalized)
"""
struct FloatIterator{T, Range}
    range::Range
end

function FloatIterator(::Type{Float32}; targetlength::Integer=10_000, positive::Bool=true, constraint=:machine_eps)
    if constraint == :normalized
        every = round(Int, length(POS_NORM_RANGE_32) / targetlength)
    elseif constraint == :machine_eps
        every = round(Int, length(POS_EPS_RANGE_32) / targetlength)
    else
        every = round(Int, length(POS_RANGE_32) / targetlength)
    end

    FloatIterator(Float32, every, positive=positive, constraint=constraint)
end

function FloatIterator(::Type{Float64}; targetlength::Integer=10_000, positive::Bool=true, constraint=:machine_eps)
    if constraint == :normalized
        every = round(UInt64, length(POS_NORM_RANGE_64) / targetlength)
    elseif constraint == :machine_eps
        every = round(Int, length(POS_EPS_RANGE_64) / targetlength)
    else
        every = round(UInt64, length(POS_RANGE_64) / targetlength)
    end
    FloatIterator(Float64, every, positive=positive, constraint=constraint)
end

function FloatIterator(::Type{Float32}, every::Integer; positive::Bool=true, constraint=:machine_eps)
    if positive && constraint == :machine_eps
        range = POS_EPS_RANGE_32.start:convert(UInt32, every):POS_RANGE_32.stop
    elseif positive && constraint == :normalized
        range = POS_NORM_RANGE_32.start:convert(UInt32, every):POS_RANGE_32.stop
    elseif positive
        range = POS_RANGE_32.start:convert(UInt32, every):POS_RANGE_32.stop
    elseif constraint == :machine_eps
        range = POS_EPS_RANGE_32.start:convert(UInt32, every):POS_RANGE_32.stop
    elseif constraint == :normalized
        range = NEG_EPS_RANGE_32.start:convert(UInt32, every):NEG_RANGE_32.stop
    else
        range = NEG_RANGE_32.start:convert(UInt32, every):NEG_RANGE_32.stop
    end
    FloatIterator{Float32, typeof(range)}(range)
end
function FloatIterator(::Type{Float64}, every::Integer; positive::Bool=true, constraint=:machine_eps)
    if positive && constraint == :machine_eps
        range = POS_EPS_RANGE_64.start:convert(UInt64, every):POS_RANGE_64.stop
    elseif positive && constraint == :normalized
        range = POS_NORM_RANGE_64.start:convert(UInt64, every):POS_RANGE_64.stop
    elseif positive
        range = POS_RANGE_64.start:convert(UInt64, every):POS_RANGE_64.stop
    elseif constraint == :machine_eps
        range = POS_EPS_RANGE_64.start:convert(UInt64, every):POS_RANGE_64.stop
    elseif constraint == :normalized
        range = NEG_EPS_RANGE_64.start:convert(UInt64, every):NEG_RANGE_64.stop
    else
        range = NEG_RANGE_64.start:convert(UInt64, every):NEG_RANGE_64.stop
    end
    FloatIterator{Float64, typeof(range)}(range)
end

Base.start(iter::FloatIterator) = start(iter.range)
function Base.next(iter::FloatIterator{T}, state) where T
    k, nextstate = next(iter.range, state)
    reinterpret(T, k), nextstate
end
Base.done(iter::FloatIterator, state) = done(iter.range, state)
Base.length(iter::FloatIterator) = length(iter.range)
Base.eltype(::Type{FloatIterator{T, R}}) where {T, R} = T
