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

## delete the previously generated files
rm *.edr *.gro *.log *.tpr *.trr *.cpt *.xtc *.xvg *.mdp

# Define the init-lambda values
#lambdas=(0.0 0.2 0.4 0.6 0.8 1.0)
input_files="../../inputs"
min_nsteps=10000
prod_steps=100000
init_lambda=0
delta_lambda="0.00001"
# Create a file with the desired content
cat << EOF > em_0.mdp
; VARIOUS PREPROCESSING OPTIONS
title                    =
include                  =
define                   = -DFLEXIBLE ;-DPOSRES

; RUN CONTROL PARAMETERS
integrator               = steep;lbfgs;steep
; Start time and timestep in ps
tinit                    = 0
dt                       = 0.001
nsteps                   = $min_nsteps
;

ld_seed = -1
; For exact run continuation or redoing part of a run
init_step                = 0
; mode for center of mass motion removal
comm-mode                = Linear
; number of steps for center of mass motion removal
nstcomm                  = 1
nstcalcenergy		 = 1
; group(s) for center of mass motion removal
comm-grps                =

; ENERGY MINIMIZATION OPTIONS
; Force tolerance and initial step-size
emtol                    = 100
emstep                   = 0.001
; Max number of iterations in relax_shells
niter                    = 0
; Step size (1/ps^2) for minimization of flexible constraints
fcstep                   = 0
; Frequency of steepest descents steps when doing CG
nstcgsteep               = 1000
nbfgscorr                = 10

; OUTPUT CONTROL OPTIONS
; Output frequency for coords (x), velocities (v) and forces (f)
nstxout                  = 0
nstvout                  = 0
nstfout                  = 0
; Checkpointing helps you continue after crashes
nstcheckpoint            = 1000
; Output frequency for energies to log file and energy file
nstlog                   = 10000
nstenergy                = 50000
; Output frequency and precision for xtc file
nstxtcout                = 0
xtc-precision            = 1000
; This selects the subset of atoms for the xtc file. You can
; select multiple groups. By default all atoms will be written.
xtc-grps                 =
; Selection of energy groups
energygrps               =

; NEIGHBORSEARCHING PARAMETERS
; nblist update frequency
cutoff-scheme = verlet
nstlist                  = 10
; ns algorithm (simple or grid)
ns-type                  = Grid
; Periodic boundary conditions: xyz (default), no (vacuum)
; or full (infinite systems only)
pbc                      = xyz
; nblist cut-off
rlist                    = 1.2
domain-decomposition     = no

; OPTIONS FOR ELECTROSTATICS AND VDW
; Method for doing electrostatics
coulombtype              = PME
rcoulomb-switch          = 0
rcoulomb                 = 1.1
; Dielectric constant (DC) for cut-off or DC of reaction field
epsilon-r                = 1
; Method for doing Van der Waals
vdw-type                 = switch
; cut-off lengths
rvdw-switch              = 1.0
rvdw                     = 1.1
; Apply long range dispersion corrections for Energy and Pressure
DispCorr                 = EnerPres
; Extension of the potential lookup tables beyond the cut-off
table-extension          = 1
; Spacing for the PME/PPPM FFT grid
fourierspacing           = 0.12
; FFT grid size, when a value is 0 fourierspacing will be used
fourier_nx               = 0
fourier_ny               = 0
fourier_nz               = 0
; EWALD/PME/PPPM parameters
pme_order                = 4
ewald_rtol               = 1e-05
ewald_geometry           = 3d
epsilon_surface          = 0
optimize_fft             = no

; GENERALIZED BORN ELECTROSTATICS
; Algorithm for calculating Born radii
gb_algorithm             = Still
; Frequency of calculating the Born radii inside rlist
nstgbradii               = 1
; Cutoff for Born radii calculation; the contribution from atoms
; between rlist and rgbradii is updated every nstlist steps
rgbradii                 = 2
; Salt concentration in M for Generalized Born models
gb_saltconc              = 0

; IMPLICIT SOLVENT (for use with Generalized Born electrostatics)
implicit_solvent         = No

; OPTIONS FOR WEAK COUPLING ALGORITHMS
; Temperature coupling
tcoupl                   = v-rescale
; Groups to couple separately
tc-grps                  = System
; Time constant (ps) and reference temperature (K)
tau-t                    = 0.1
ref-t                    = 298
; Pressure coupling
Pcoupl                   = Parrinello-Rahman
Pcoupltype               = Isotropic
; Time constant (ps), compressibility (1/bar) and reference P (bar)
tau-p                    = 5
compressibility          = 4.6E-5
ref-p                    = 1
; Random seed for Andersen thermostat
andersen_seed            = 815131

; SIMULATED ANNEALING
; Type of annealing for each temperature group (no/single/periodic)
annealing                = no
; Number of time points to use for specifying annealing in each group
annealing_npoints        = 2
; List of times at the annealing points for each group
annealing_time           = 0 250
; Temp. at each annealing point, for each group.
annealing_temp           = 0 300

; GENERATE VELOCITIES FOR STARTUP RUN
gen-vel                  = no
gen-temp                 = 298
gen-seed                 = 173529

; OPTIONS FOR BONDS
constraints              = none;all-bonds
; Type of constraint algorithm
constraint-algorithm     = Lincs
; Do not constrain the start configuration
unconstrained-start      = yes
; Use successive overrelaxation to reduce the number of shake iterations
Shake-SOR                = no
; Relative tolerance of shake
shake-tol                = 1e-04
; Highest order in the expansion of the constraint coupling matrix
lincs-order              = 6
; Number of iterations in the final step of LINCS. 1 is fine for
; normal simulations, but use 2 to conserve energy in NVE runs.
; For energy minimization with constraints it should be 4 to 8.
lincs-iter               = 2
; Lincs will write a warning to the stderr if in one step a bond
; rotates over more degrees than
lincs-warnangle          = 30
; Convert harmonic bonds to morse potentials
morse                    = no

; ENERGY GROUP EXCLUSIONS
; Pairs of energy groups for which all non-bonded interactions are excluded
energygrp_excl           =

; NMR refinement stuff
; Distance restraints type: No, Simple or Ensemble
disre                    = No
; Force weighting of pairs in one distance restraint: Conservative or Equal
disre-weighting          = Equal
; Use sqrt of the time averaged times the instantaneous violation
disre-mixed              = no
disre-fc                 = 1000
disre-tau                = 0
; Output frequency for pair distances to energy file
nstdisreout              = 100
; Orientation restraints: No or Yes
orire                    = no
; Orientation restraints force constant and tau for time averaging
orire-fc                 = 0
orire-tau                = 0
orire-fitgrp             =
; Output frequency for trace(SD) to energy file
nstorireout              = 100
; Dihedral angle restraints: No, Simple or Ensemble
dihre                    = No
dihre-fc                 = 1000
dihre-tau                = 0
; Output frequency for dihedral values to energy file
nstdihreout              = 100

; Free energy control stuff
free-energy              = yes
init-lambda              = ${init_lambda}
delta-lambda             = 0 
sc-alpha                 = 0.3
sc-sigma                 = 0.25
sc-power                 = 1
sc-coul                  = yes
;alpha_Q = 0.3
;sigma_Q = 1.0

refcoord-scaling = all


; Non-equilibrium MD stuff
acc-grps                 =
accelerate               =
freezegrps               =
freezedim                =
cos-acceleration         = 0

; Electric fields
; Format is number of terms (int) and for all terms an amplitude (real)
; and a phase angle (real)
E-x                      =
E-xt                     =
E-y                      =
E-yt                     =
E-z                      =
E-zt                     =

; User defined thingies
user1-grps               =
user2-grps               =
userint1                 = 0
userint2                 = 0
userint3                 = 0
userint4                 = 0
userreal1                = 0
userreal2                = 0
userreal3                = 0
userreal4                = 0
EOF

# Create a file with the desired content
cat << EOF > eq_${init_lambda}.mdp
; VARIOUS PREPROCESSING OPTIONS
title                    =
include                  =
define                   =

; RUN CONTROL PARAMETERS
integrator               = sd
; Start time and timestep in ps
tinit                    = 0
dt                       = 0.001
nsteps                   = $prod_steps
;6 ns

ld_seed = -1
; For exact run continuation or redoing part of a run
init_step                = 0
; mode for center of mass motion removal
comm-mode                = Linear
; number of steps for center of mass motion removal
nstcomm                  = 100
nstcalcenergy		 = 100
nstdhdl			= 10000
; group(s) for center of mass motion removal
comm-grps                =

; ENERGY MINIMIZATION OPTIONS
; Force tolerance and initial step-size
emtol                    = 100
emstep                   = 0.01
; Max number of iterations in relax_shells
niter                    = 0
; Step size (1/ps^2) for minimization of flexible constraints
fcstep                   = 0
; Frequency of steepest descents steps when doing CG
nstcgsteep               = 1000
nbfgscorr                = 10

; OUTPUT CONTROL OPTIONS
; Output frequency for coords (x), velocities (v) and forces (f)
nstxout                  = 23500
nstvout                  = 23500
nstfout                  = 0
; Checkpointing helps you continue after crashes
nstcheckpoint            = 1000
; Output frequency for energies to log file and energy file
nstlog                   = 10000
nstenergy                = 23500
; Output frequency and precision for xtc file
nstxtcout                = 23500
xtc-precision            = 1000
; This selects the subset of atoms for the xtc file. You can
; select multiple groups. By default all atoms will be written.
xtc-grps                 =
; Selection of energy groups
energygrps               =

; NEIGHBORSEARCHING PARAMETERS
; nblist update frequency
cutoff-scheme = verlet
nstlist                  = 40
; ns algorithm (simple or grid)
ns-type                  = Grid
; Periodic boundary conditions: xyz (default), no (vacuum)
; or full (infinite systems only)
pbc                      = xyz
; nblist cut-off
rlist                    = 1.2
domain-decomposition     = no

; OPTIONS FOR ELECTROSTATICS AND VDW
; Method for doing electrostatics
coulombtype              = PME
rcoulomb-switch          = 0
rcoulomb                 = 1.0
; Dielectric constant (DC) for cut-off or DC of reaction field
epsilon-r                = 1
; Method for doing Van der Waals
vdw-type                 = switch
; cut-off lengths
rvdw-switch              = 0.8
rvdw                     = 1.0
; Apply long range dispersion corrections for Energy and Pressure
DispCorr                 = EnerPres
; Extension of the potential lookup tables beyond the cut-off
table-extension          = 1
; Spacing for the PME/PPPM FFT grid
fourierspacing           = 0.12
; FFT grid size, when a value is 0 fourierspacing will be used
fourier_nx               = 0
fourier_ny               = 0
fourier_nz               = 0
; EWALD/PME/PPPM parameters
pme_order                = 4
ewald_rtol               = 1e-05
ewald_geometry           = 3d
epsilon_surface          = 0
optimize_fft             = no

; GENERALIZED BORN ELECTROSTATICS
; Algorithm for calculating Born radii
gb_algorithm             = Still
; Frequency of calculating the Born radii inside rlist
nstgbradii               = 1
; Cutoff for Born radii calculation; the contribution from atoms
; between rlist and rgbradii is updated every nstlist steps
rgbradii                 = 2
; Salt concentration in M for Generalized Born models
gb_saltconc              = 0.15

; IMPLICIT SOLVENT (for use with Generalized Born electrostatics)
implicit_solvent         = No

; OPTIONS FOR WEAK COUPLING ALGORITHMS
; Temperature coupling
tcoupl                   = v-rescale
; Groups to couple separately
tc-grps                  = System
; Time constant (ps) and reference temperature (K)
tau-t                    = 2.0
ref-t                    = 298
; Pressure coupling
Pcoupl                   = Parrinello-Rahman
Pcoupltype               = Isotropic
; Time constant (ps), compressibility (1/bar) and reference P (bar)
tau-p                    = 5
compressibility          = 4.6E-5
ref-p                    = 1
; Random seed for Andersen thermostat
andersen_seed            = 815131

; SIMULATED ANNEALING
; Type of annealing for each temperature group (no/single/periodic)
annealing                = no
; Number of time points to use for specifying annealing in each group
annealing_npoints        = 2
; List of times at the annealing points for each group
annealing_time           = 0 250
; Temp. at each annealing point, for each group.
annealing_temp           = 0 298

; GENERATE VELOCITIES FOR STARTUP RUN
gen-vel                  = no
gen-temp                 = 298
gen-seed                 = 173529

; OPTIONS FOR BONDS
constraints              = all-bonds
; Type of constraint algorithm
constraint-algorithm     = Lincs
; Do not constrain the start configuration
unconstrained-start      = yes
; Use successive overrelaxation to reduce the number of shake iterations
Shake-SOR                = no
; Relative tolerance of shake
shake-tol                = 1e-04
; Highest order in the expansion of the constraint coupling matrix
lincs-order              = 4
; Number of iterations in the final step of LINCS. 1 is fine for
; normal simulations, but use 2 to conserve energy in NVE runs.
; For energy minimization with constraints it should be 4 to 8.
lincs-iter               = 2
; Lincs will write a warning to the stderr if in one step a bond
; rotates over more degrees than
lincs-warnangle          = 30
; Convert harmonic bonds to morse potentials
morse                    = no

; ENERGY GROUP EXCLUSIONS
; Pairs of energy groups for which all non-bonded interactions are excluded
energygrp_excl           =

; NMR refinement stuff
; Distance restraints type: No, Simple or Ensemble
disre                    = No
; Force weighting of pairs in one distance restraint: Conservative or Equal
disre-weighting          = Equal
; Use sqrt of the time averaged times the instantaneous violation
disre-mixed              = no
disre-fc                 = 1000
disre-tau                = 0
; Output frequency for pair distances to energy file
nstdisreout              = 100
; Orientation restraints: No or Yes
orire                    = no
; Orientation restraints force constant and tau for time averaging
orire-fc                 = 0
orire-tau                = 0
orire-fitgrp             =
; Output frequency for trace(SD) to energy file
nstorireout              = 100
; Dihedral angle restraints: No, Simple or Ensemble
dihre                    = No
dihre-fc                 = 1000
dihre-tau                = 0
; Output frequency for dihedral values to energy file
nstdihreout              = 100

; Free energy control stuff
free-energy              = yes
init-lambda              = ${init_lambda}
delta-lambda             = ${delta_lambda}
sc-alpha                 = 0.3
sc-sigma                 = 0.25
sc-power                 = 1
sc-coul                  = yes
;alpha_Q                 = 0.3
;sigma_Q                 = 1.0
calc-lambda-neighbors    = 1 
dhdl-print-energy        = yes

refcoord-scaling = all


; Non-equilibrium MD stuff
acc-grps                 =
accelerate               =
freezegrps               =
freezedim                =
cos-acceleration         = 0

; Electric fields
; Format is number of terms (int) and for all terms an amplitude (real)
; and a phase angle (real)
E-x                      =
E-xt                     =
E-y                      =
E-yt                     =
E-z                      =
E-zt                     =

; User defined thingies
user1-grps               =
user2-grps               =
userint1                 = 0
userint2                 = 0
userint3                 = 0
userint4                 = 0
userreal1                = 0
userreal2                = 0
userreal3                = 0
userreal4                = 0
EOF

outfile="md_${init_lambda}"
gmx grompp -f em_${init_lambda}.mdp -c $input_files/solv_ions.gro -p $input_files/topol.top -o em_${init_lambda}.tpr -maxwarn 5
gmx mdrun -v -deffnm em_${init_lambda}
gmx grompp -f eq_${init_lambda}.mdp -c em_${init_lambda}.gro -r em_${init_lambda}.gro -p $input_files/topol.top -o eq_${init_lambda}.tpr -maxwarn 5
gmx mdrun -s eq_${init_lambda}.tpr -ntomp 4 -deffnm $outfile 
