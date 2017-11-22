import Base: promote_rule, convert

promote_rule(::Type{Performance}, ::Type{Accuracy}) = Accuracy
promote_rule(::Type{Double{T1,E1}}, ::Type{Double{T2,E2}}) where {T1<:SysFloat,T2<:SysFloat,E1<:Emphasis,E2<:Emphasis} = Double{promote_type(T1,T2), promote_type(E1, E2)}
promote_rule(::Type{Double{T,E}}, ::Type{Rational{I}}) where {I<:Integer, T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{BigInt}) where {T<:SysFloat, E<:Emphasis} = BigFloat
promote_rule(::Type{Double{T,E}}, ::Type{BigFloat}) where {T<:SysFloat, E<:Emphasis} = BigFloat
promote_rule(::Type{Double{T,E}}, ::Type{<:Real}) where {T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{<:Union{Float32, Float16}}) where {T<:SysFloat, E<:Emphasis} = Double{Float32,E}
convert(::Type{Double{T,E}}, x::Irrational) where {T<:SysFloat, E<:Emphasis} = convert(Double{T,E}, big(x))
convert(::Type{Double{T,E}}, x::Rational{<:Integer}) where {T<:SysFloat, E<:Emphasis} = convert(Double{T,E}, float(x))
function convert(::Type{Double{T,E}}, x::R) where {T<:SysFloat, E<:Emphasis, R<:Real}
    hi = convert(T, x)
    lo = convert(T, x - convert(R, hi))
    return Double{T, E}(hi, lo)
end
convert(::Type{T}, x::Double{Float64, E}) where {T<:Union{Float16, Float32, Float64}, E<:Emphasis} = convert(T, x.hi)
convert(::Type{T}, x::Double{Float64, E}) where {T<:Union{Float16, Float32}, E<:Emphasis} = convert(T, x.hi)
convert(::Type{Float64}, x::Double{T, E}) where {T<:Union{Float16, Float32}, E<:Emphasis} = Float64(x.hi) + Float64(x.lo)
convert(::Type{BigFloat}, x::Double) = big(x.hi) + big(x.lo)
convert(::Type{BigInt}, x::Double) = convert(BigInt, convert(BigFloat, x))
convert(::Type{Rational{I}}, x::Double) where {I<:Integer} = Rational{I}(convert(BigFloat, x))
convert(::Type{I}, x::Double) where {I<:Integer} = convert(I, convert(BigInt, x))
