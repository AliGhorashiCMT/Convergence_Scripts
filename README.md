# Convergence_Scripts

This is modeled after the Abinit "Double DataSet" capability which allows, for instance, one to check the convergence of a DFT calculation with increased plane wave cutoffs and increased kpoint sampling. The scripts included here are written in Julia and write out bash scripts with arbitrarily nested For loops. The written bash script defines environment variables var1, var2...varn which can be included in a JDFTX input file. In such a case, we obtain an nth order dataset. Note that environment variables may be included in a JDFTX input file by using ${var1}. This also works for things like include statements. For instance, if one has many different supercell calculations (multiplicities (2, 2, 2), (3, 3, 3), (4, 4, 4), for instance), one may write "include ions${var1}${var1}${var1}.ionpos" in the scf calculation input file. 

Note: 
