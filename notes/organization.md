## DoubleDouble

### Doubles

> #### Doubles are extended precision floating point values.

A Double stores information with an ordered pairing of two Float64s, or Float32s, or Float16s. The more significant member of the pairing is named 'hi', the less significant member is named 'lo'.  Doubles have a sign bit; it is the most significant bit of the more significant member, the sign bit of the value of greater magnitude.  While the the sign bit of a Double informs the value of that *double*, the sign of lesser member pertains only to the 'lo' part.

| float type | significand  |   exponent   | bias  |
|:----------:|-------------:|-------------:|------:|
| Float64    |  106 bits    |   11 bits    | 1023  |
| Float32    |   48 bits    |    8 bits    |  127  |       
| Float16    |   22 bits    |    5 bits    |   15  |


