
module MyPkg0

export sog
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
        if lenv == 1
            return [true]
        end

        if lenv >= 2
            #temp = [iVector[i][1] for i in 1:len]
            oVector = Vector{Bool}(undef, lenv)
            oVector[1] = Bool(1)
            for i in 2:lenv
                oVector[i] = !isequal([iVector[j][i] for j in 1:len], [iVector[j][i-1] for j in 1:len])    
            end
            return oVector
        end 
    end
    
    if len == 1
        return [true]
    end
    
    oVector0 = append!([1], diff(iVector))
    oVector = Vector{Bool}(replace(!iszero, oVector0))
    

    """
    oVector = Vector{Bool}(undef, len)
    oVector[1] = Bool(1)
    for i in 2:len
        oVector[i] = !isequal(iVector[i], iVector[i-1])
    end
    """


    return oVector
end
end
