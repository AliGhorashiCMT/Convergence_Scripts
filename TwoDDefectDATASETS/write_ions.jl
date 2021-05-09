function write_ions_lattice(prefix::String, ext::String, small_lattice::Vector{<:Vector{<:Real}}, small_ionpos::Vector{<:Tuple{String, <:Real, <:Real, <:Real, <:Integer}}, cell_mults::Vector{<:Vector{<:Integer}}, defect_atom::String)
	for mults in cell_mults
		##Make large lattice:	
		large_lattice = small_lattice.*mults
		##Make large ionpos:
		large_ionpos = Vector{Tuple{String, Float64, Float64, Float64, Int64}}()
		for (index, ion) in enumerate(small_ionpos)
			starting_pos = ion[2:4]./mults
			ion_id = ion[1]
			for (xiter, yiter, ziter) in Tuple.(CartesianIndices(rand(mults...)))
				x, y, z = xiter-1, yiter-1, ziter-1
				println([x, y, z]./mults)
				if index==1 && [x, y, z]==[0, 0, 0]  
					push!(large_ionpos, (defect_atom, (starting_pos+[x, y, z]./mults )..., ion[5]))
				else
					push!(large_ionpos, (ion_id, (starting_pos+[x, y, z]./mults )..., ion[5]))
				end
			end
		end
		##Change to JDFTX Array format 
		large_lattice_array = Array{Float64, 2}(undef, (3, 3))
		for lvec in 1:3
			large_lattice_array[:, lvec] = large_lattice[lvec]
		end
		##Write IONS
		open("$(prefix)$(mults[1:2]...)$(ext).ionpos", write=true, create=true) do io 
			for large_ion in large_ionpos
				write(io, "ion ")
				for ionspec in large_ion
					write(io, string(" ", ionspec, " "))
				end
				write(io, " HyperPlane 0 0 1\n")
			end
		end	
		##Write Lattice
		open("$(prefix)$(mults[1:2]...)$(ext).lattice", write=true, create=true) do io 
			write(io, "lattice \\ \n")
			for (index, row) in enumerate(eachrow(large_lattice_array))
				for coord in row 
					write(io, string(coord), " ")
				end
				index==3 ? write(io, "\n") : write(io, "\\ \n")
			end
		end
	end
end

function write_ions_lattice(prefix::String, ext::String, small_lattice::Vector{<:Vector{<:Real}}, small_ionpos::Vector{<:Tuple{String, <:Real, <:Real, <:Real, <:Integer}}, cell_mults::Vector{<:Integer}, defect_atom::String)
	mults = Vector{Vector{Int64}}()
	for mult in cell_mults
		push!(mults, [mult, mult, 1])
	end
	println("writing ionpos/lattice files for: ", mults)
	write_IONS_LATTICE(prefix, ext, small_lattice, small_ionpos, mults, defect_atom)
end

"""
Writes a bash script to run SCF_MAIN.in and BANDSTRUCT_MAIN.in
"""
function write_script(prefix::String, extensions::Vector{<:String}, charges::Vector{<:Real}, nks::Vector{<:Real}, wfncutoff::Real, densitycutoff::Real, mults::Vector{<:Integer}; makexsf::Bool=true, gpu::Bool=true, relaxiterations::Integer=3, numprocesses::Union{Nothing, <:Integer}=nothing)
	(!isnothing(numprocesses) && gpu) && error("Cannot define numprocesses for gpu enabled calculations")
	##Write Script
	println("Writing Bash Script")
	open("RUN_MAIN.sh", write=true, create=true) do io
		write(io, string("#!/bin/bash \n"))
		write(io, "export wfncutoff=$(wfncutoff)\n")
		write(io, "export densitycutoff=$(densitycutoff)\n")
		##Loop over extensions, cell mults, and do SCF, Bandstruct and Wannier calculations for all
		write(io, "for mult in $([string(" ", m) for m in mults]...); do\n")
		write(io, "\texport mult\n")
		write(io, "\texport prefix=$(prefix) \n")
		for (nk, charge, ext) in zip(nks, charges, extensions)
			write(io, "\texport ext=$ext\n")
			write(io, "\texport charge=$charge\n")
			write(io, "\texport nk=$nk\n")
			write(io, "\tfor i in {0..$(relaxiterations)}; do\n")
			gpu ? write(io, "\t \t jdftx_gpu -i SCF_MAIN.in | tee -a $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".out\n") : write(io, "\t \t mpirun -n $(numprocesses) jdftx -i SCF_MAIN.in | tee -a $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".out\n")
			write(io, "\tdone\n")
			makexsf ? write(io, " \tcreateXSF $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".out $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".xsf \n") : println("No output of xsf files")
			gpu ? write(io, "\tjdftx_gpu -i BANDSTRUCT_MAIN.in |tee $(prefix)\"\$mult\"\"\$mult\"\"\$ext\"Bands.out\n" ) : write(io, "\tmpirun -n $(numprocesses) jdftx -i BANDSTRUCT_MAIN.in |tee $(prefix)\"\$mult\"\"\$mult\"\"\$ext\"Bands.out\n" )
		end
		write(io, "done\n")
	end
end

"Write bandstruct.kpoints for bandstructure calculations"
function write_kpoints(kvec_coords::Vector{<:Vector{<:Real}}, kvec_labels::Vector{<:AbstractString}, spacing::Real)
    total_kvecs = Vector{Vector{Any}}()
    for (index, coord) in enumerate(kvec_coords)
        push!(total_kvecs, ["kpoint", coord..., kvec_labels[index]])
    end
    open("bandstruct.kpoints.in", "w") do io
            writedlm(io, total_kvecs); write(io, " \n ")
    end;
    run(`bandstructKpoints bandstruct.kpoints.in $(spacing) bandstruct`) 
    rm("bandstruct.kpoints.in")
    rm("bandstruct.plot")
end

"""
Pass in the prefix, mults, and the extensions as well as the number of orbitals per atom and obtain randomly located wannier
orbitals centered around the ions from the relevant ionpos coordinates.
"""
function write_wanniercenters(prefix::String, mults::Vector{<:Integer}, extensions::Vector{<:String}, norbitals::Integer)
	for ext in extensions
		for mult in mults
			wanniercenters = Vector{Vector{Float64}}()
			ions = readlines(prefix*string(mult)*string(mult)*ext*".ionpos")
			for ion in ions
				ioncoords = parse.(Float64, string.(split(ion))[3:5])
				for o in 1:norbitals
					push!(wanniercenters, ioncoords+rand(3)./100)
				end
			end
			open(prefix*string(mult)*string(mult)*ext*".wanniercenters", write=true) do io 
				for center in wanniercenters
					write(io, "wannier-center Gaussian ", [string(c, " ") for c in center ]..., "\n")
				end
			end
		end
	end
end
