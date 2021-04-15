coulomb-interaction Slab 001 

include ${prefix}${mult}${mult}${ext}.ionpos
include ${prefix}${mult}${mult}${ext}.lattice

ion-species SG15/$ID_ONCV_PBE.upf
elec-cutoff ${wfncutoff} ${densitycutoff}
elec-initial-charge ${charge}
elec-initial-magnetization 1 no 
spintype z-spin

dump-name ${prefix}${mult}${mult}${ext}Bands.$VAR
dump End BandEigs

fix-electron-density ${prefix}${mult}${mult}${ext}.$VAR
include bandstruct.kpoints
 
elec-smearing Fermi 0.0001
elec-ex-corr gga-PBE

