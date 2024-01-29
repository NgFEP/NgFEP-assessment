#!/bin/bash

INPUT=namd3_input.in 
NAMDHOME=/home/saikat/softwares/NAMD_3.0b5_Linux-x86_64-multicore-CUDA/
device="RTX_4070"
SLURM_CPUS_PER_TASK=1

for index in {1..5}; do
	outfile="gpu_cuda_${device}_${index}.out"
	$NAMDHOME/namd3 +p${SLURM_CPUS_PER_TASK} +idlepoll ${INPUT} > $outfile
done

cat /proc/cpuinfo | grep "model name" | uniq
grep  TIMING: gpu_cuda_${device}_*.out | awk '{printf "Performance %f %s ",\$9,\$10}'
echo -n $1 "GPUs, " 
hostname -s

# Output file
output_file="${device}_results_namd.dat"
temp_file="tmpl"

# Clear the output and temporary files if they already exist
rm "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_${device}_*.out; do
    if [[ -f "$file" ]]; then
        # Calculate the line number for the last 10th line
        total_lines=$(wc -l < "$file")
        line_number=$((total_lines - 23))

        # Extracting the last 10th line from each file
        last_line=$(sed -n "${line_number}p" "$file")

        # Writing the results to the temporary file
        echo "$last_line" >> "$temp_file"
#        echo "" >> "$temp_file"
    fi
done

# Extract ns/day values and write them to the output file
grep "averaging " tmpl | awk '{print $4}' > "$output_file"

## Optional: Remove temporary file
rm "$temp_file"


echo "Extracted data saved to $output_file"

