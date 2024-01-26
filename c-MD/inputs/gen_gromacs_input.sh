#!/bin/bash
# Loop over the output file indices
gmx grompp -p topol.top  -c restart.gro -t restart.trr -f gromacs_production.mdp

