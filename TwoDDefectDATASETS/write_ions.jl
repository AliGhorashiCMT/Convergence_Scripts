function write_IONS_LATTICE(prefix::String, ext::String, small_lattice::Vector{<:Vector{<:Real}}, small_ionpos::Vector{<:Tuple{String, <:Real, <:Real, <:Real, <:Integer}}, cell_mults::Vector{<:Vector{<:Integer}}, defect_atom::String)
	for mults in cell_mults
		##Make large lattice:	
		large_lattice = small_lattice.*mults
		##Make large ionpos:
		large_ionpos = Vector{Tuple{String, Float64, Float64, Float64, Int64}}()
		for (index, ion) in enumerate(small_ionpos)
			starting_pos = ion[2:4]./mults
			ion_id = ion[1]
			for z in 0:mults[3]-1
				for y in 0:mults[2]-1
					for x in 0:mults[1]-1
						println([x, y, z]./mults)
						if index==1 && [x, y, z]==[0, 0, 0]  
							push!(large_ionpos, (defect_atom, (starting_pos+[x, y, z]./mults )..., ion[5]))
						else
							push!(large_ionpos, (ion_id, (starting_pos+[x, y, z]./mults )..., ion[5]))
						end
					end
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
					write(io, string(ionspec), "  ")
				end
				write(io, "\n")
			end
		end	
		##Write Lattice
		open("$(prefix)$(mults[1:2]...)$(ext).lattice", write=true, create=true) do io 
			write(io, "lattice \\ \n")
			for row in eachrow(large_lattice_array)
				for coord in row 
					write(io, string(coord), " ")
				end
				write(io, "\\ \n")
			end
		end
	end
end
function write_script(prefix::String, extensions::Vector{<:String}, charges::Vector{<:Real}, nks::Vector{<:Real}, wfncutoff::Real, densitycutoff::Real, mults::Vector{<:Integer}; makexsf::Bool=true)
	##Write Script
	open("RUN_MAIN.sh", write=true, create=true) do io
		write(io, string("#!/bin/bash \n"))
		write(io, "export wfncutoff=$(wfncutoff)\n")
		write(io, "export densitycutoff=$(densitycutoff)\n")
		##Loop over extensions, cell mults, and do SCF, Bandstruct and Wannier calculations for all
		write(io, "for mult in $([string(" ", m) for m in mults]...); do\n")
		write(io, "export mult\n")
		write(io, "export prefix=$(prefix)")
		for (nk, charge, ext) in zip(nks, charges, extensions)
			write(io, "export ext=$ext\n")
			write(io, "export charge=$charge\n")
			write(io, "export nk=$nk\n")
			write(io, "for i in {0..3} do\n")
			write(io, "jdftx_gpu -i SCF_MAIN.in | tee $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".out\n")
			write(io, "done\n")
			makexsf ? write(io, "createXSF $(prefix)\"\$mult\"\"\$mult\"\"\$ext\".out $(prefix)\"\$mult\"\"\$mult\".xsf \n") : println("No output of xsf files")
			write(io, "jdftx_gpu -i BANDSTRUCT_MAIN.in |tee $(prefix)\$\"mult\"\$\"mult\".out\n" )
		end
		write(io, "done\n")
	end
end

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