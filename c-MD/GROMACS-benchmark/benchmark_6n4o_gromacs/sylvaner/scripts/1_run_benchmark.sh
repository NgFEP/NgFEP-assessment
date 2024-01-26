#!/bin/bash
# Loop over the output file indices
gmx grompp -p topol.top  -c restart.gro -t restart.trr -f gromacs_production.mdp

device=0

for index in {1..5}; do
        # Set CUDA_VISIBLE_DEVICES
        export CUDA_VISIBLE_DEVICES=$device
	export OMP_NUM_THREADS=4
        # Define the output file based on the device and index
	outfile="gpu_cuda_${device}_${index}"
        # Run the GMX command with the specified output file
	gmx mdrun -s topol.tpr -ntomp 4 -nb gpu -pme gpu -update gpu -bonded cpu -deffnm $outfile
done


#gmx grompp -p topol.top  -c restart.gro -t restart.trr -f gromacs_production.mdp

#td=$SLURM_TMPDIR
#wd=$SLURM_SUBMIT_DIR
#cp topol.tpr $td && cd $td

#export CUDA_VISIBLE_DEVICES=0
#export OMP_NUM_THREADS=8
##gmx mdrun -s topol.tpr -cpi state.cpi
#gmx mdrun -ntomp 8 -nb gpu -pme gpu -update gpu -bonded cpu -s topol.tpr > a.out

