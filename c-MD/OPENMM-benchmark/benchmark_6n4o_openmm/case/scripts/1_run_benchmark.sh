#!/bin/bash
# Loop over the CUDA_VISIBLE_DEVICES values
cuda_device=(0 1 2)

for device in "${cuda_device[@]}"; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device

    outfile="gpu_cuda_${device}_${index}.out"

    # Run the pmemd.cuda command with the specified output file
    python openmm_input.py > $outfile

  done
done

#python openmm_input.py > cuda_0_run_1.out 
