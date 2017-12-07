FloatIterator is an iterator to iterate a uniform sample from the space of Float32 or Float64 numbers.

For example

FloatIterator(Float32, targetlength=100, positive=true, constraint=:machine_eps)
will generate 100 positive Float32 numbers uniformly distributed with a minimal size of eps(Float32). constraint can also be :normalized (only normalized numbers),
:denormalized (all numbers including denormalized). The default is :machine_eps. positive indicates the sign (it would have been a little bit cumbersome to iterate over the positives and negatives at the same time).

Instead of targetlength you can also say that you want to use every n-th floating point number. This would be done with

n = 10_000
FloatIterator(Float32, n)
Everything works the same for Float64.

Note that the iterator generates all numbers on the fly, i.e. besides computing time it will not be a problem to test a huge amount of numbers.
