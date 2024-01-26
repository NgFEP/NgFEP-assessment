#!/bin/bash
# Loop over the CUDA_VISIBLE_DEVICES values
for device in {0..2}; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device
    export OMP_NUM_THREADS=4
    # Define the output file based on the device and index
    outfile="gpu_cuda_${device}_${index}"
    # Run the GMX command with the specified output file
    gmx mdrun -s topol.tpr -ntomp 4 -nb gpu -pme gpu -update gpu -bonded cpu -deffnm $outfile
  done
done


