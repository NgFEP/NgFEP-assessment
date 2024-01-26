#!/bin/bash
#SBATCH --job-name=bench
#SBATCH --partition=cgpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1
#SBATCH --time=2-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
#SBATCH --mail-user=saikat.pal@rutgers.edu
#SBATCH --nodelist=gpuc003

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
$gpuamber -O -i pmemd_prod.in -p prmtop.parm7 -c restart.rst7 -o $outfile
done


