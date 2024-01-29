#!/bin/bash
# Loop over the output file indices
device=0
for index in {1..5}; do
	# Set CUDA_VISIBLE_DEVICES
	export CUDA_VISIBLE_DEVICES=$device
	# Define the output file based on the device and index
	if [ "$device" -eq 0 ]; then
		outfile="gpu_cuda_${device}_${index}.out"
	else
		outfile="gpu_cuda_${device}_${index}.out"
	fi
	# Run the pmemd.cuda command with the specified output file
	python openmm_input.py > $outfile
done

#python openmm_input.py > cuda_0_run_1.out 
