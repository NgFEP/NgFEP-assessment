#!/bin/bash

# Loop over the CUDA_VISIBLE_DEVICES values
for device in {0..2}; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device
    outfile="gpu_cuda_${device}_${index}.out"

    # Run the pmemd.cuda command with the specified output file
    pmemd.cuda -O -i pmemd_prod.in -p prmtop.parm7 -c restart.rst7 -o $outfile

  done
done

