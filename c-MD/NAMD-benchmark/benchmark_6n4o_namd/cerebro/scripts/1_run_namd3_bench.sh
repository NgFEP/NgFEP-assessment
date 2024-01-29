#!/bin/bash
SLURM_CPUS_PER_TASK=1

INPUT=namd3_input.in
NAMDHOME=/home/sp2546/softwares/NAMD_3.0b5_Linux-x86_64-multicore-CUDA/

#nvidia-smi -L 
for device in {0..2}; do
        for index in {1..5}; do
                export CUDA_VISIBLE_DEVICES=$device
                outfile="gpu_cuda_${device}_${index}.out"
                $NAMDHOME/namd3 +p${SLURM_CPUS_PER_TASK} +idlepoll ${INPUT} > $outfile

        done
done
~                                        
