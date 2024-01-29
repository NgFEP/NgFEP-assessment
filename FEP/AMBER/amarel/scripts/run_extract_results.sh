#!/bin/bash
#SBATCH --job-name=ti_bench
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
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

source /home/sp2546/softwares/AMBER/amber22/amber.sh

device="A100"
rm *.out

mdin="pmemd_prod.in"
prmtop="prmtop.parm7"
inpcrd="restart.rst7"

gpuamber="pmemd.cuda"
#mpi_gpuamber="time mpirun -np 2 pmemd.cuda.MPI"
#mpi_gpuamber="time mpirun --oversubscribe pmemd.cuda.MPI"
#mpi_gpuamber="time mpirun --host host1:2 pmemd.cuda.MPI"

#$gpuamber -O -i mdin -p prmtop -c inpcrd.equil -o gpu_1.out
#$mpi_gpuamber -O -i mdin -p prmtop -c inpcrd.equil -o gpu_2.out 
#$mpi_gpuamber -O -i mdin -p prmtop -c inpcrd.equil -o gpu_8.out

# Loop over the output file indices
for index in {1..5}; do
outfile="gpu_cuda_${device}_${index}.out"
# Run the pmemd.cuda command with the specified output file
$gpuamber -O -p unisc.parm7 -c 0.60000000_preTI.rst7 -i 0.60000000_ti.mdin -o $outfile -r 0.60000000_ti.rst7 -x 0.60000000_ti.nc -ref 0.60000000_preTI.rst7
done

# Output file
output_file="${device}_results_amber.dat"
temp_file="tmpl"

# Clear the output and temporary files if they already exist
rm "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_${device}_*.out; do
    if [[ -f "$file" ]]; then
        # Calculate the line number for the last 10th line
        total_lines=$(wc -l < "$file")
        line_number=$((total_lines - 9))

        # Extracting the last 10th line from each file
        last_line=$(sed -n "${line_number}p" "$file")

        # Writing the results to the temporary file
        echo "$last_line" >> "$temp_file"
#        echo "" >> "$temp_file"
    fi
done

# Extract ns/day values and write them to the output file
grep "ns/day =" "$temp_file" | awk '{print $4}' > "$output_file"

## Optional: Remove temporary file
 rm "$temp_file"

echo "Extracted data saved to $output_file"
