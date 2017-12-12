import Base: promote_rule, convert

promote_rule(::Type{Performance}, ::Type{Accuracy}) = Accuracy

promote_rule(::Type{Double{Float64, E}}, ::Type{Double{Float32, E}}) where E<:Emphasis = Double{Float64, E}
promote_rule(::Type{Double{Float64, E}}, ::Type{Double{Float16, E}}) where E<:Emphasis = Double{Float64, E}
promote_rule(::Type{Double{Float32, E}}, ::Type{Double{Float16, E}}) where E<:Emphasis = Double{Float32, E}
promote_rule(::Type{Double{T, Accuracy}}, ::Type{Double{T, Performance}}) where {T<:SysFloat} = Double{T, EMPHASIS}
promote_rule(::Type{Double{T1, Accuracy}}, ::Type{Double{T2, Performance}}) where {T1<:SysFloat, T2<:SysFloat} =
  Double{promote_type(T1,T2), EMPHASIS}

promote_rule(::Type{Double{T1,E1}}, ::Type{Double{T2,E2}}) where {T1<:SysFloat,T2<:SysFloat,E1<:Emphasis,E2<:Emphasis} =
  Double{promote_type(T1,T2), promote_type(E1, E2)}
promote_rule(::Type{Double{T,E}}, ::Type{Rational{I}}) where {I<:Integer, T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{BigInt}) where {T<:SysFloat, E<:Emphasis} = BigFloat
promote_rule(::Type{Double{T,E}}, ::Type{BigFloat}) where {T<:SysFloat, E<:Emphasis} = BigFloat
promote_rule(::Type{Double{T,E}}, ::Type{<:Real}) where {T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{<:Union{Float32, Float16}}) where {T<:SysFloat, E<:Emphasis} = Double{Float32,E}

convert(::Type{Double{T, E}}, x::Double{T, E}) where {T<:SysFloat, E<:Emphasis} = x
convert(::Type{Double{T, Accuracy}}, x::Double{T, Performance}) where T<:SysFloat =
    Double{T, Accuracy}(x.hi, x.lo)
convert(::Type{Double{T, Performance}}, x::Double{T, Accuracy}) where T<:SysFloat =
    Double{T, Performance}(x.hi, x.lo)

convert(::Type{Double{Float64, Accuracy}}, x::Double{Float32, Performance}) =
    Double{T, Accuracy}(two_sum(Float64(x.hi), Float64(x.lo)...))
convert(::Type{Double{Float64, Performance}}, x::Double{Float32, Accuracy}) =
    Double{T, Performance}(two_sum(Float64(x.hi), Float64(x.lo)...))
convert(::Type{Double{Float64, Accuracy}}, x::Double{Float16, Performance}) =
    Double{T, Accuracy}(two_sum(Float64(x.hi), Float64(x.lo)...))
convert(::Type{Double{Float64, Performance}}, x::Double{Float16, Accuracy}) =
    Double{T, Performance}(two_sum(Float64(x.hi), Float64(x.lo)...))
convert(::Type{Double{Float32, Accuracy}}, x::Double{Float16, Performance}) =
    Double{T, Accuracy}(two_sum(Float32(x.hi), Float42(x.lo)...))
convert(::Type{Double{Float32, Performance}}, x::Double{Float16, Accuracy}) =
    Double{T, Performance}(two_sum(Float32(x.hi), Float32(x.lo)...))

convert(::Type{Double{Float64, E}}, x::Double{Float32, E}) where E<:Emphasis =
  Double{Float64, E}(two_sum(Float64(x.hi), Float64(x.lo))...)
convert(::Type{Double{Float64, E}}, x::Double{Float16, E}) where E<:Emphasis =
  Double{Float64, E}(two_sum(Float64(x.hi), Float64(x.lo))...)
convert(::Type{Double{Float32, E}}, x::Double{Float16, E}) where E<:Emphasis =
  Double{Float64, E}(two_sum(Float32(x.hi), Float32(x.lo))...)

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
