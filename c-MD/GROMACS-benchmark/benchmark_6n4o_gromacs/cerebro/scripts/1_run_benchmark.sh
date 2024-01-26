#!/bin/bash
# Loop over the output file indices
gmx grompp -p topol.top  -c restart.gro -t restart.trr -f gromacs_production.mdp

# Loop over the CUDA_VISIBLE_DEVICES values
for device in {0..3}; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device
    outfile="gpu_cuda_${device}_${index}.out"

    # Run the pmemd.cuda command with the specified output file
    gmx mdrun -s topol.tpr -ntomp 4 -nb gpu -pme gpu -update gpu -bonded cpu -deffnm $outfile

  done
done



