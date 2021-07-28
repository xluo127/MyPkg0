
module Sog1

    export sog
    """
        sog(x)

    The function sog() takes a `Vector` of any type `x` as its input with any possible length (default is Any[]), and will return a `Bool Vector` with the same length as input. Values
     `true` or `false` in the output depends on whether one element in the `Vector` is the start of a group or not. The sog() will return 
     'nothing' if the length of input is 0. As any type can be applied in the input, be careful! To check whether two elements `a` and `b` are treated
    as the same, please call `isequal(a, b)` to see the result. 

    Examples:

        sog([1,2,2,2,1,3,3,1,1]) returns: [true, true, false, false, true, true, false, true, false]
        sog() returns: nothing
        sog(["a", "a", "a", 'a']) returns: [true, false, false, true]

    """
    function sog(x=[])                       
        if x == []
            return nothing
        end

        len = length(x)
        iVector = x 
        if len == 1
            return [true]
        end
    
        oVector = Vector{Bool}(undef, len)
        oVector[1] = Bool(1)
        for i in 2:len
            oVector[i] = !isequal(iVector[i], iVector[i-1])
        end
        return oVector
    end
end

