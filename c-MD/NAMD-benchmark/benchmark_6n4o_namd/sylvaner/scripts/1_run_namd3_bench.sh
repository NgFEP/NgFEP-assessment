#!/bin/bash
SLURM_CPUS_PER_TASK=1

INPUT=namd3_input.in 
NAMDHOME=/home/saikat/softwares/NAMD_3.0b5_Linux-x86_64-multicore-CUDA/

#nvidia-smi -L 

for index in {1..5}; do
	outfile="gpu_cuda_0_${index}.out"
	$NAMDHOME/namd3 +p${SLURM_CPUS_PER_TASK} +idlepoll ${INPUT} > $outfile
done

cat /proc/cpuinfo | grep "model name" | uniq
grep  TIMING: gpu_cuda_0_*.out | awk '{printf "Performance %f %s ",\$9,\$10}'
echo -n $1 "GPUs, " 
hostname -s

