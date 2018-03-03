const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"    # and prepend "Double"

function Base.show(io::IO, x::Double{T,EMPHASIS}) where T<:SysFloat
    return print(io, EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.show(io::IO, x::Double{T,ALT_EMPHASIS}) where T<:SysFloat
    return print(io, ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
