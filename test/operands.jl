setprecision(300)

function op_test(op, ::Type{T}, ::Type{E}, precision, N; min_argument=-Inf, max_argument=Inf) where {T, E}
     failures = Vector{Tuple{Double{T, E}, Double{T, E}}}()
     for x in DoubleIterator(T, E, targetlength=N)
          for y in DoubleIterator(T, E, targetlength=N)
               if x > max_argument || y > max_argument ||
                  x < min_argument || y < min_argument
                  continue
               end
               a = big(x)
               b = big(y)
               result = op(x, y)
               if !isnan(result)
                    accurate = op(a, b)
                    if big(result) / accurate > (big(1) + big(precision))
                         push!(failures, (x, y))
                    end
               end
          end
     end
     failures
end


@test op_test(+, Float32, Accuracy, 1e-14, 1000) |> isempty
@test op_test(-, Float32, Accuracy, 1e-14, 1000) |> isempty
@test op_test(*, Float32, Accuracy, 1e-13, 1000) |> isempty
@test op_test(/, Float32, Accuracy, 1e-14, 1000, max_argument=1e20) |> isempty

@test op_test(+, Float64, Accuracy, 1e-31, 1000) |> isempty
@test op_test(-, Float64, Accuracy, 1e-31, 1000) |> isempty
@test op_test(*, Float64, Accuracy, 1e-31, 1000) |> isempty
@test op_test(/, Float64, Accuracy, 1e-31, 1000, max_argument=1e20) |> isempty


x = Double(rand(), 0.00001 * rand())
@test -lo(x) == lo(-x)
@test -hi(x) == hi(-x)
