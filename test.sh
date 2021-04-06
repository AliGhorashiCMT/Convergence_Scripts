for var1 in 9 2 3 ; do
	echo running calculation for var1 = $var1
	export var1
	for var2 in 10 20 5 ; do
		echo running calculation for var2 = $var2
		export var2
		for var3 in 1 2 3 ; do
			echo running calculation for var3 = $var3
			export var3
			export dump=Si$var1$var2$var3.$VAR
			mpirun -n 20 jdftx -i Si.in | tee Si$var1$var2$var3.out
		done 
	done 
done 
