#!/bin/bash
cat <<eof >mdin
 short md, nve ensemble; "production" DHFR run from Amber web site
 &cntrl
   ntx=5, irest=1,
   ntc=2, ntf=2, tol=0.000001, 
   nstlim=10000, 
   ntpr=1000, ntwx=1000, ntwr=10000, 
   dt=0.002,
   cut=8.,
   ntt=0, ioutfm=1,
 /
 &ewald
  dsum_tol=0.000001,
 /
eof

# Loop from 1 to 5
for i in {1..5}
do
  export CUDA_VISIBLE_DEVICES=0
  pmemd.cuda -O -i mdin -c inpcrd.equil -o gpu_${i}.out
done
#rm mdin restrt
