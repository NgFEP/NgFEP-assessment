#!/bin/bash
#SBATCH --job-name=bench
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gres=gpu:1
#SBATCH --time=2-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
#SBATCH --mail-user=saikat.pal@rutgers.edu
#SBATCH --nodelist=gpu[015-016,019-026]

module purge
module use /projects/community/modulefiles
module load gcc/10.2.0/openmpi/4.0.5-bz186
module load cmake/3.19.5-bz186
module load cuda/11.7.1

source /home/sp2546/softwares/gromacs/bin/GMXRC

#gmx grompp -p topol.top  -c restart.gro -t restart.trr -f gromacs_production.mdp

device="A100"

for index in {1..5}; do
        # Set CUDA_VISIBLE_DEVICES
	export OMP_NUM_THREADS=4
        # Define the output file based on the device and index
	outfile="gpu_cuda_${device}_${index}"
        # Run the GMX command with the specified output file
	gmx mdrun -s topol.tpr -ntomp 4 -nb gpu -pme gpu -update gpu -bonded cpu -deffnm $outfile
done

# Output file
output_file="${device}_results_gromacs.dat"
temp_file="tmpl"

# Clear the output and temporary files if they already exist
rm "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_${device}_*.log; do
    if [[ -f "$file" ]]; then
        # Calculate the line number for the last 10th line
        total_lines=$(wc -l < "$file")
        line_number=$((total_lines - 2))

        # Extracting the last 10th line from each file
        last_line=$(sed -n "${line_number}p" "$file")

        # Writing the results to the temporary file
        echo "$last_line" >> "$temp_file"
#        echo "" >> "$temp_file"
    fi
done

# Extract ns/day values and write them to the output file
grep "Performance: " tmpl | awk '{print $2}' > "$output_file"

## Optional: Remove temporary file
rm "$temp_file"


echo "Extracted data saved to $output_file"

