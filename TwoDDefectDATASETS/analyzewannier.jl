function wannierbandranges(bandrange::AbstractString)
    for (indx, line) in enumerate(readlines(bandrange))
        println(indx, " ", parse.(Float64, String.(split(line))))
    end
end

function wannierbandranges(bandrange1::AbstractString, bandrange2::AbstractString)
    for (indx, (line1, line2)) in enumerate(zip(readlines(bandrange1), readlines(bandrange2)))
        println(indx, " Up: ", parse.(Float64, String.(split(line1))), " Dn: ",  parse.(Float64, String.(split(line2))))
    end
end

function finddefectband(eigstats::AbstractString, bandrange::AbstractString)
    μ = nothing
    for line in readlines(eigstats)
        contains(line, "mu") && (μ = parse(Float64, String.(split(line))[3]))
    end
    abses=Float64[]
    for (indx, line) in enumerate(readlines(bandrange))
        l, u =  parse.(Float64, String.(split(line)))
        push!(abses, abs(l-μ)^2+abs(u-μ)^2)
    end
    println(argmin(abses))
end

function findisolatedbands(bandrange::String; tolerance::Real=0)
    ranges = Vector{Tuple{Float64, Float64 }}()
    isolatedbands = Vector{Integer}()
    for (indx, line) in enumerate(readlines(bandrange))
        l, u =  parse.(Float64, String.(split(line)))
        push!(ranges, (l, u))
    end
    for (idx, rangetuple) in enumerate(ranges)
        diffs = Vector{Float64}()
        try
            push!(diffs, (rangetuple[1]-ranges[idx-1][2]-tolerance) )
        catch
        end
        try
            push!(diffs, (ranges[idx+1][1]-rangetuple[2]-tolerance) )
        catch
        end
        (sum(diffs .> 0) == length(diffs))&& push!(isolatedbands, idx)
    end
    println(isolatedbands)
end