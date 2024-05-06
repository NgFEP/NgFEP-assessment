#!/bin/bash
#Author: Saikat Pal, PhD, https://scholar.google.co.in/citations?user=l720qe0AAAAJ&hl=en 
source /usr/local/gromacs/bin/GMXRC
#export GMXLIB="/usr/local/gromacs/share/gromacs/top"

ligand1="1h1r"
########################
rm topol.top
gmx pdb2gmx -f protein_only.pdb -o protein.pdb -p topol.top -ter -ignh -ff amber99sb -water tip4p

#########################
sed -i '21a\#include "ffmerged_1.itp"' topol.top
sed -i '22a\#include "merged_1.itp"' topol.top
echo 'MOL                 1' >> topol.top
###########################
rm complex.pdb 
cat protein.pdb mergedA.pdb > complex.pdb
gmx editconf -f complex.pdb -o newbox.gro -bt triclinic -d 1.6  
##########################
gmx solvate -cp newbox.gro -cs tip4p.gro -p topol.top -o solv.gro -maxsol 32523


#####
rm em_ion.mdp
cat << EOF >> em_ion.mdp
; LINES STARTING WITH ';' ARE COMMENTS
title		    = Minimization	; Title of run

; Parameters describing what to do, when to stop and what to save
integrator	    = steep	; Algorithm (steep = steepest descent minimization)
emtol		    = 1000.0  	; Stop minimization when the maximum force < 10.0 kJ/mol
emstep              = 0.01      ; Energy step size
nsteps		    = 50000	; Maximum number of (minimization) steps to perform

; Parameters describing how to find the neighbors of each atom and how to calculate the interactions
nstlist		    = 1	        ; Frequency to update the neighbor list and long range forces
cutoff-scheme       = Verlet
ns_type		    = grid 	; Method to determine neighbor list (simple, grid)
rlist		    = 1.0	; Cut-off for making neighbor list (short range forces)
coulombtype	    = cutoff	; Treatment of long range electrostatic interactions
rcoulomb	    = 1.0	; long range electrostatic cut-off
rvdw		    = 1.0	; long range Van der Waals cut-off
pbc                 = xyz	; Periodic Boundary Conditions
EOF
###

gmx grompp -f em_ion.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 5

echo "SOL" | gmx genion -s ions.tpr -o solv_ions.gro -p topol.top -np 88 -pname NA -nn 88 -nname CL -neutral 
