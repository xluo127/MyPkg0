module MyPkg0

using DataFrames

export sog, tmpsog, zo, zo1, zo3, newsog, newsog2, newsog3, newsog4, select_if
"""
    sog(x)

The function `sog()` takes a `Vector` of any type `x` as its input with any possible length, and will return a `Bool Vector` with the same length as input. Values
 `true` or `false` in the output depends on whether one element in the `Vector` is the start of a group or not. The sog() will return 
 'nothing' if the length of input is 0. As any type can be applied in the input, be careful! To check whether two elements `a` and `b` are treated
as the same, please call `isequal(a, b)` to see the result. 

When taking `Vector` of `Vectors`, the length of output should the same as the length of every `Vector`, and what `sog()` do is to compare 
one element with the previous one on the same position for each `Vector`.

Examples:
≡≡≡≡≡≡≡≡≡≡≡≡≡≡

    sog([1,2,2,2,1,3,3,1,1]) returns: [true, true, false, false, true, true, false, true, false]
    sog() returns: nothing
    sog(["a", "a", "a", 'a']) returns: [true, false, false, true]
    sog([[1, 1, 1, 2, 2], [1.5, 1.5, 20.0, 3.0, 3.0]] returns: [true, false, true, true, false]

"""
function sog(x=[])                       
    if x == []
        return nothing
    end

    iVector = x
    len = length(x)
    #lenv = length(x[1])

    if typeof(iVector[1]) <: Vector{}           #For Vector of Vectors
        lenv = length(x[1])
        if lenv == 0
            return nothing 
        end    

        if lenv == 1
            return [true]
        end

        if lenv >= 2
            r0 = map(sog, iVector)
            rInt = Vector{Vector{Int64}}(r0)
            oVector = Vector{Bool}(replace(!iszero, sum(rInt)))

            return oVector
        end 
    end
    
    if len == 1
        return [true]
    end
    
    r = iVector[1:(len-1)] .=== iVector[2:len]
    r1 = Vector{Bool}(replace(iszero, r))
    oVector = Vector{Bool}(append!([1], r1))


    return oVector
end



function zo(re, xi)
    for j in 2:length(re)
        re[j] = re[j]==1 ? 1 : !(xi[j]===xi[j-1])
    end
    return re
end
    
    
function tmpsog(x)
    re = zeros(Bool, length(x[1]))
    re[1] = 1
    for i in 1:length(x)
        re = zo(re, x[i])
    end
    return re
end

function zo1(re, xi)
    for j in 2:length(re)
        @inbounds re[j] = re[j]==1 ? 1 : !(xi[j]===xi[j-1])
    end
    return re
end
    
    
function newsog(x)
    re = zeros(Bool, length(x[1]))
    re[1] = 1
    for i in 1:length(x)
        re = zo1(re, x[i])
    end
    return re
end




function ini0(x1)
    len = length(x1)
    re = zeros(Bool, len)
    re[1] = 1
    for j in 2:len
        @inbounds re[j] = !(x1[j]===x1[j-1])
    end
    return re
end


function newsog2(x)
    re = ini0(x[1])
    for i in 2:length(x)
        re = zo1(re, x[i])
    end
    return re
end

function zo3(re, xi)
    Threads.@threads for j in 2:length(re)
        @inbounds re[j] = re[j]==1 ? 1 : !(xi[j]===xi[j-1])
    end
    return re
end
    
    
function newsog3(x)
    re = ini0(x[1])
    for i in 2:length(x)
        re = zo3(re, x[i])
    end
    return re
end

function newsog4(x, orders = eachindex(x))
    if length(eachindex(x)) != length(orders)
        println("Please specify the order of columns correctly! Number of columns is the length of order.")
        return nothing
    end
    re = ini0(x[orders[1]])
    for i in orders[2:end]
        re = zo3(re, x[i])
    end
    return re
end



"""
    select_if(df, predicate, elementwise_or_not, any_or_all)

This function is aim to select `DataFrame` columns based on a predicate applied to the columns or a logical vector. 

Keyword arguments

≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡

    •  `df` is the DataFrame.

    •  `predicate` can be a predicate function for columns or a `Bool` `Vector` with the length of number of columns.

    •  `elementwise_or_not` takes a `Bool` value that is `true` in default. Change `elementwise_or_not` to `false` will
   let the predicate apply to the DataFrame columnwise.

    •  `any_or_all` also takes a `Bool` value with a default value `true` and it determinesto apply any or all predicate
   to the DataFrame when `elementwise_or_not` = `true`.


Examples

≡≡≡≡≡≡≡≡≡≡≡≡≡≡

```
julia> df1 = DataFrame([missing 1 2 3; missing 2 missing 4; 1 4 2 5], :auto)
3×4 DataFrame
 Row │ x1       x2      x3       x4
     │ Int64?   Int64?  Int64?   Int64?
─────┼──────────────────────────────────
   1 │ missing       1        2       3
   2 │ missing       2  missing       4
   3 │ 1             4        2       5

julia> select_if(df1, [false, true, true, true])
3×3 DataFrame
 Row │ x2      x3       x4
     │ Int64?  Int64?   Int64?
─────┼─────────────────────────
   1 │      1        2       3
   2 │      2  missing       4
   3 │      4        2       5

julia> select_if(df1, !ismissing, 1, 0)
3×2 DataFrame
 Row │ x2      x4
     │ Int64?  Int64?
─────┼────────────────
   1 │      1       3
   2 │      2       4
   3 │      4       5

julia> pre1 = (function(col) return mean(skipmissing(col)) >= 4 end)

julia> select_if(df1, pre1, elementwise_or_not = 0)
3×1 DataFrame
 Row │ x4
     │ Int64?
─────┼────────
   1 │      3
   2 │      4
   3 │      5

```
"""
function select_if(df::DataFrame, predicate, ;elementwise_or_not = true, any_or_all = true)
    if typeof(predicate) == Vector{Bool}
        indices = predicate
    elseif Bool(elementwise_or_not) == true
        if any_or_all == true 
            indices = map(x -> any(predicate, x), eachcol(df))
        else
            indices = map(x -> all(predicate, x), eachcol(df))
        end
    else
       indices = predicate.(eachcol(df))
    end
    return df[:, indices]
end




end