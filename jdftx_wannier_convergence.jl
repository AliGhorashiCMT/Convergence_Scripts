function find_chemicalpotential(outputfile::String)
    ##Find the chemical potential
    lastmuline = last(filter(x->contains(x, "mu"), readlines(outputfile)))
    idx = nothing
    for (index, splitstring) in enumerate(split(lastmuline))
        contains(splitstring, "mu") && (idx = index)
    end
    idx isa Nothing && error("No mention of chemical potential in output file")

    μ = parse(Float64, String(split(lastmuline)[idx+1]))
    println("The chemical potential is: ", μ)
end
