#!/bin/bash
for var1 in 2 4 6 12 ; do
	echo running calculation for var1 = $var1
	export var1
	for var2 in 10 20 ; do
		echo running calculation for var2 = $var2
		export var2
		for var3 in 100 120 200 ; do
			echo running calculation for var3 = $var3
			export var3
			export dump=Si$var1$var2$var3.'$VAR' 
			mpirun -n 4 jdftx -i Si.in | tee Si$var1$var2$var3.out
		done 
	done 
done 