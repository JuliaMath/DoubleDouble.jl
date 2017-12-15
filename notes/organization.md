## DoubleDouble

> #### Doubles are extended precision floating point values.

A Double stores information with an ordered pairing of two Float64s, or Float32s, or Float16s. The more significant member of the pairing is named 'hi', the less significant member is named 'lo'.  Doubles have a sign bit; it is the most significant bit of the more significant member, the sign bit of the value of greater magnitude.  While the the sign bit of a Double informs the value of that *double*, the sign of lesser member pertains only to the 'lo' part.

| underlying |
| float type | si
|------------|
using Float64 holds: sign, significand, and exponent.and binary exponenthas sign + 106 s


> keeping it as two Float64s, or as two Float32s, or as two Float16s.
