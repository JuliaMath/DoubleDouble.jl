"""
DoubleIterator(::Type{<:Union{Float32, Float64}}, ::Type{<:Emphasis}; nslp_rands=4, targetlength=10_000, positive=true, constraint=:machine_eps)

Create an iterator over all possible floating point numbers of the respective type.
* `targetlength` is the number of uniform samples.
* `positive` is whether positive or negative numbers should be sampled.
* `constraint` limits the number of possible floating points numbers. Possible values are
`:machine_eps` (no number smaller than machine epsilon), `:normalized` (only normalized numbers),
`:denormalized` (all numbers including denormalized)
"""
struct DoubleIterator{T, Range, E<:Emphasis}
    float_iter::FloatIterator{T, Range}
    emphasis::Type{E}
    slp_rands::Vector{Int}
end


function DoubleIterator(::Type{T}, ::Type{E}; nslp_rands=4, kwargs...) where {T, E<:Emphasis}
    slp_rands = [i-1 for i in 1:nslp_rands for _=1:Int(2^nslp_rands * 0.5^i)]
    DoubleIterator(FloatIterator(T; kwargs...), E, slp_rands)
end

function DoubleIterator(::Type{T}, ::Type{E}, every::Integer; nslp_rands=4, kwargs...) where {T, E<:Emphasis}
    slp_rands = [i-1 for i in 1:nslp_rands for _=1:Int(2^nslp_rands * 0.5^i)]
    DoubleIterator(FloatIterator(T, every; kwargs...), E, slp_rands)
end

Base.start(iter::DoubleIterator) = start(iter.float_iter)
function Base.next(iter::DoubleIterator{T}, state) where T
    r1, nextstate = next(iter.float_iter, state)
    r2 = rand(T)
    x, exp = frexp(r2)
    r3 = ldexp(x, exp + slp(r1) - rand(iter.slp_rands))
    d = Double{T, iter.emphasis}(r1, r3)

    d, nextstate
end
Base.done(iter::DoubleIterator, state) = done(iter.float_iter, state)
Base.length(iter::DoubleIterator) = length(iter.float_iter)
Base.eltype(::Type{DoubleIterator{T, R, E}}) where {T, R, E} = Double{T, E}
