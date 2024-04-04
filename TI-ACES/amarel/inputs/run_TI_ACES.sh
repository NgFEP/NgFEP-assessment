#!/bin/bash
#SBATCH --job-name=24-w-aces
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --gres=gpu:4
#SBATCH --time=3-00:00:00
#SBATCH --error=job.%J.err
#SBATCH --output=job.%J.out
#SBATCH --mail-user=saikat.pal@rutgers.edu
#SBATCH --nodelist=gpu[007-014]

module purge
module use /projects/community/modulefiles
module load gcc/10.2.0/openmpi/4.0.5-bz186
module load cmake/3.19.5-bz186
module load cuda/11.7.1

source /home/sp2546/softwares/AMBER/amber22/amber.sh

lams=(0.00000000 0.04500000 0.09000000 0.13500000 0.18000000 0.22500000 0.27000000 0.31500000 0.36000000 0.40500000 0.45000000 0.49500000 0.54000000 0.58500000 0.63000000 0.67500000 0.72000000 0.76500000 0.81000000 0.85500000 0.90000000 0.94500000 0.99000000 1.00000000)
# check if AMBERHOME is set
if [ -z "${AMBERHOME}" ]; then echo "AMBERHOME is not set" && exit 0; fi

EXE=${AMBERHOME}/bin/pmemd.cuda.MPI
echo "running replica ti"
## -rem 3 is Hamiltonian replica exchange
mpirun -np ${#lams[@]} ${EXE} -rem 3 -remlog remt.log -ng ${#lams[@]} -groupfile inputs/ti.groupfile
#mpirun -np ${#lams[@]} ${EXE} -rem 3 -remlog remt${trial}.log -ng ${#lams[@]} -groupfile inputs/ti.groupfile
