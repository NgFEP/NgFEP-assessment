#!/bin/bash

# Loop over the CUDA_VISIBLE_DEVICES values
for device in {0..2}; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device
    outfile="gpu_cuda_${device}_${index}.out"

    # Run the pmemd.cuda command with the specified output file
    pmemd.cuda -O -p unisc.parm7 -c 0.60000000_preTI.rst7 -i 0.60000000_ti.mdin -o $outfile -r 0.60000000_ti.rst7 -x 0.60000000_ti.nc -ref 0.60000000_preTI.rst7

  done
done

