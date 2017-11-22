# !!TODO!! remove as much of this as possible while keeping case coverage

import Base: promote_rule, convert

promote_rule(::Type{Double{T,Accuracy}}, ::Type{Double{T,Performance}}) where T<:SysFloat = Double{T,Accuracy}
promote_rule(::Type{Double{Float64,E}}, ::Type{Double{Float32,E}}) where E<:Emphasis = Double{Float64,E}
promote_rule(::Type{Double{Float64,E}}, ::Type{Double{Float16,E}}) where E<:Emphasis = Double{Float64,E}
promote_rule(::Type{Double{Float32,E}}, ::Type{Double{Float16,E}}) where E<:Emphasis = Double{Float32,E}
promote_rule(::Type{Double{T1,E1}}, ::Type{Double{T2,E2}}) where {T1<:SysFloat,T2<:SysFloat,E1<:Emphasis,E2<:Emphasis} =
   Double{promote_type(T1,T2), Accuracy}

promote_rule(::Type{Double{T,E}}, ::Type{Rational{I}}) where {I<:Integer, T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{BigInt}) where {T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{BigFloat}) where {T<:SysFloat, E<:Emphasis} = Double{Float64,E}
promote_rule(::Type{Double{T,E}}, ::Type{R}) where {R<:Real, T<:SysFloat, E<:Emphasis} = Double{Float64,E}

Base.convert(::Type{Float64}, x::Double{Float64, E}) where E<:Emphasis = x.hi
Base.convert(::Type{Float64}, x::Double{Float32, E}) where E<:Emphasis = Float64(x.hi)
Base.convert(::Type{Float64}, x::Double{Float16, E}) where E<:Emphasis = Float64(x.hi)
Base.convert(::Type{Float32}, x::Double{Float64, E}) where E<:Emphasis = Float32(x.hi)
Base.convert(::Type{Float32}, x::Double{Float32, E}) where E<:Emphasis = x.hi
Base.convert(::Type{Float32}, x::Double{Float16, E}) where E<:Emphasis = Float32(x.hi)
Base.convert(::Type{Float16}, x::Double{Float64, E}) where E<:Emphasis = Float16(x.hi)
Base.convert(::Type{Float16}, x::Double{Float32, E}) where E<:Emphasis = Float16(x.hi)
Base.convert(::Type{Float16}, x::Double{Float16, E}) where E<:Emphasis = x.hi

convert(::Type{Double{T,Accuracy}}, x::Double{T,Performance}) where T<:SysFloat = Double(Accuracy, x.hi, x.lo)
convert(::Type{Double{T,Performance}}, x::Double{T,Accuracy}) where T<:SysFloat = Double(Performance, x.hi, x.lo)
convert(::Type{Double{T,Accuracy}}, x::Double{T,Performance}) where T<:SysFloat = Double(Accuracy, x.hi, x.lo)
convert(::Type{Double{T,Performance}}, x::Double{T,Accuracy}) where T<:SysFloat = Double(Performance, x.hi, x.lo)

function convert(::Type{Double{Float64,E}}, x::BigInt) where {E<:Emphasis}
    hi = Float64(x)
    lo = Float64(x - BigInt(hi))
    return Double(E, hi, lo)
end

function convert(::Type{Double{Float64,E}}, x::Rational{I}) where {I<:Integer, E<:Emphasis}
    hi = Float64(x)
    lo = Float64(x - I(hi))
    return Double(E, hi, lo)
end

function convert(::Type{Double{Float64,E}}, x::BigFloat) where {E<:Emphasis}
    hi = Float64(x)
    lo = Float64(x - BigFloat(hi))
    return Double(E, hi, lo)
end

function convert(::Type{Double{Float64,E}}, x::R) where {R<:Real, T<:SysFloat, E<:Emphasis}
    hi = Float64(x)
    lo = Float64(x - R(hi))
    return Double(E, hi, lo)
end


function convert(::Type{BigFloat}, x::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
   return parse(BigFloat, string(x.hi)) + parse(BigFloat, string(x.lo))
end

function convert(::Type{BigInt}, x::Double{T,E}) where {T<:SysFloat, E<:Emphasis}
   return round(BigInt, parse(BigFloat, string(x.hi)) + parse(BigFloat, string(x.lo)))
end

function convert(::Type{Rational{I}}, x::Double{T,E}) where {I<:Integer, T<:SysFloat, E<:Emphasis}
   bf = convert(BigFloat, x)
   return Rational{I}(bf)
end

function convert(::Type{I}, x::Double{T,E}) where {I<:Integer, T<:SysFloat, E<:Emphasis}
   bi = convert(BigInt, x)
   return I(bi)
end

function convert(::Type{R}, x::Double{T,E}) where {R<:Real, T<:SysFloat, E<:Emphasis}
   bf = convert(BigFloat, x)
   return round(R, bf)
end

Double(::Type{E}, x::Irrational) where E<:Emphasis = convert(Double{Float64,E},BigFloat(x))
Double(x::Irrational) = Double(EMPHASIS, x)
Base.convert(::Type{Double{T,E}}, x::Irrational) where {T<:SysFloat, E<:Emphasis} = Double(E, x)

