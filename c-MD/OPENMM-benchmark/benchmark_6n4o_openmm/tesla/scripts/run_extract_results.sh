#!/bin/bash
#conda activate vmd-python
echo "Activating conda environment"
eval "$($(which conda) 'shell.bash' 'hook')"
conda activate openmm
###
# Loop over the output file indices
device="RTX_4070"
for index in {1..5}; do
	# Set CUDA_VISIBLE_DEVICES
	export CUDA_VISIBLE_DEVICES=0
	outfile="gpu_cuda_${device}_${index}.out"
	#Run the pmemd.cuda command with the specified output file
	python openmm_input.py > $outfile
done

# Output file
output_file="${device}_results_openmm.dat"
rm $output_file

# Loop through files matching the pattern
for file in gpu_cuda_${device}_*.out; do
    if [[ -f "$file" ]]; then
        # Extracting the first and last line from each file
        first_line=$(head -n 1 "$file")
        last_line=$(tail -n 1 "$file")

        # Writing the results to the output file
        echo "File: $file" >> "tmpl"
        echo "First Line: $first_line" >> "tmpl"
        echo "Last Line: $last_line" >> "tmpl"
        echo "" >> "tmpl"
    fi
done

# Extract ns/day values and write them to the output file
grep "Benchmark time" "tmpl" | awk '{print $5}' > "$output_file"
rm tmpl

# Display a message when done
echo "Extracted data saved to $output_file"

