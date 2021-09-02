module MyPkg0

export sog, tmpsog, zo, zo1, zo3, newsog, newsog2, newsog3, newsog4
"""
    sog(x)

The function `sog()` takes a `Vector` of any type `x` as its input with any possible length, and will return a `Bool Vector` with the same length as input. Values
 `true` or `false` in the output depends on whether one element in the `Vector` is the start of a group or not. The sog() will return 
 'nothing' if the length of input is 0. As any type can be applied in the input, be careful! To check whether two elements `a` and `b` are treated
as the same, please call `isequal(a, b)` to see the result. 

When taking `Vector` of `Vectors`, the length of output should the same as the length of every `Vector`, and what `sog()` do is to compare 
one element with the previous one on the same position for each `Vector`.

Examples:

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
    re = ini0(x[orders[1]])
    for i in orders[2:end]
        re = zo3(re, x[i])
    end
    return re
end


end