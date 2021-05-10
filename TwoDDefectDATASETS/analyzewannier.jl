function wannierbandranges(bandrange::String)
    for (indx, line) in enumerate(readlines(bandrange))
        println(indx, " ", parse.(Float64, String.(split(line))))
    end
end

function wannierbandranges(bandrange1::String, bandrange2::String)
    for (indx, (line1, line2)) in enumerate(zip(readlines(bandrange1), readlines(bandrange2)))
        println(indx, " Up: ", parse.(Float64, String.(split(line1))), " Dn: ",  parse.(Float64, String.(split(line2))))
    end
end

function finddefectband(eigstats::String, bandrange::String)
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
