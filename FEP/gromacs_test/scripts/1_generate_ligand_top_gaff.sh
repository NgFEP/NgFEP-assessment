#!/bin/sh
## usage of ACPYPE
#conda activate acpype
echo "Activating conda environment"
eval "$($(which conda) 'shell.bash' 'hook')"
conda activate acpype
### for help 
acpype -h

### generate parameters for ligand 
acpype -i ligand.pdb

### it will generate ligand.acpype folder where you can find the AMBER NAMD and GROMACS compatible gaff force field parameters

#####################################################################

