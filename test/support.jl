setprecision(BigFloat, 1500)



function big2d(T, b)
   hi = T(b)
   return hi
end

function big2dd(T, b)
   hi = T(b)
   b = b - BigFloat(hi)
   lo = T(b)
   return hi, lo
end

function big2ddd(T, b)
   hi = T(b)
   b = bf - BigFloat(hi)
   md = T(b)
   b = bf - BigFloat(hi) - BigFloat(md)
   lo = T(b)
   return hi, md, lo
end

function big2dddd(T, b)
   hi = T(b)
   b = bf - BigFloat(hi)
   mhi = T(b)
   b = bf - BigFloat(hi) - BigFloat(mhi)
   mlo = T(b)
   b = bf - BigFloat(hi) - BigFloat(mhi) - BigFloat(mlo)
   lo = T(b)
   return hi, mhi, mlo, lo
end


function d(T, x)
   bf = BigFloat(x)
   return big2d(bf)
end

function dd(T, x, y=0)
   bf = BigFloat(x) + BigFloat(y)
   return big2dd(bf)
end

function ddd(T, x, y=0, z=0)
   bf = BigFloat(x) + BigFloat(y) + BigFloat(z)
   return big2ddd(bf)
end

function dddd(T, w, x=0, y=0, z=0)
   bf = BigFloat(w) + BigFloat(x) + BigFloat(y) + BigFloat(z)
   return big2dddd(bf)
end

function fn_d(fn, x)
   a = d(x)
   b = BigFloat(a)
   result = fn(b)   
   return d(result)
end

function fn_dd(fn, x, y=0)
   a = dd(x,y)
   b = BigFloat(a.hi) + BigFloat(a.lo)
   result = fn(b)   
   return dd(result)
end   

function fn_ddd(fn, x, y=0, z=0)
   a = ddd(x,y,z)
   b = BigFloat(a.hi) + BigFloat(a.md) + BigFloat(a.lo)
   result = fn(b)   
   return ddd(result)
end

function fn_dddd(fn, w, x=0, y=0, z=0)
   a = dddd(w,x,y,z)
   b = BigFloat(a.hi) + BigFloat(a.mhi) + BigFloat(a.mlo) + BigFloat(a.lo)
   result = fn(b)   
   return dddd(result)
end

