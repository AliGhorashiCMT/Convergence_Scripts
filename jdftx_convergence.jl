#=
We test the convergence of a given parameter for a JDFTX calculation, given a certain input file
=#
function converge_parameters(io::IO, filebase::String)
    filename = "$filebase.in"
    write(io, "Test string" )
    return nothing
end

function write_scripts()

end

function write_inputs_1param(baseinput::String, numiterations::Integer, parameter::String, startvalue::Any, endvalue::Any)
    filename  = "$baseinput.in"
    DFT_PARAMS = Vector{String}()
    for line in readlines(filename)
        push!(DFT_PARAMS, line)
    end
    for n in 1:numiterations
        dumponce = 0
        open(string("$baseinput", n, ".in" ), "w") do io
            for line in DFT_PARAMS
                if contains(line, parameter)
                    write(io, string("#", line, "\n"))
                    write(io, string(parameter, "\t"))
                    for p in 1:length(endvalue)  
                        try
                            write(io, string(Int( (n.*(endvalue-startvalue)./numiterations + startvalue)[p]), "\a\a") )
                        catch 
                            write(io, string((n.*(endvalue-startvalue)./numiterations + startvalue)[p], "\a\a") )
                        end
                    end
                elseif contains(line, "dump-name")
                    write(io, string("#", line, "\n"))
                    if dumponce == 0 
                        write(io, string("dump-name $(baseinput)", n, ".\$VAR \n" ))
                        dumponce +=1
                    end
                else
                    write(io, string(line, "\n")) 
                end

            end
        end
    end
    return DFT_PARAMS
end

function write_inputs_2param(baseinput::String, numiterations::Vector{<:Integer}, parameters::Array{String}, startvalues::Array{<:Any}, endvalues::Array{<:Any})
    #cp("$baseinput.in", "$(baseinput)0.in", force = true)
    write_inputs_1param(baseinput, numiterations[1], parameters[1], startvalues[1], endvalues[1])
    for i in 1:numiterations[1]
        basestring = string(baseinput, i)
        write_inputs_1param(basestring, numiterations[2], parameters[2], startvalues[2], endvalues[2])
    end
    for i in 1:numiterations[1]
        cp(string(baseinput, i, ".in"), string(baseinput, i, 0, ".in"), force = true)
        rm(string(baseinput, i, ".in"))
    end
end