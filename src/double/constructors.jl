Double(::Type{E}, hi::T) where {T<:SysFloat, E<:Emphasis} = Double{T,E}(hi, zero(T))
Double(hi::SysFloat) = Double(EMPHASIS, hi)

function Double(::Type{E}, hi::T, lo::T) where {T<:SysFloat, E<:Emphasis}
    s = hi + lo
    e = (hi - s) + lo
    return Double{T,E}(s, e)
end
Double(hi::S, lo::S) where S<:SysFloat = Double(EMPHASIS, hi, lo)

Double(x::Real) = convert(Double{Float64, EMPHASIS}, x)
Double(::Type{T}, x::Real) where T<:SysFloat = convert(Double{T, EMPHASIS}, x)
Double(::Type{E}, x::Real) where E<:Emphasis = convert(Double{Float64, E}, x)

FastDouble(x::R) where R<:SysReal = Double(Performance, x)
FastDouble(x::R, y::R) where R<:SysReal = Double(Performance, x, y)
