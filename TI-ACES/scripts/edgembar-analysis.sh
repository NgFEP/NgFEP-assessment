#!/bin/bash
edge="1h1q~1h1r"
analysis="analysis"
amber_path="/home/saikat/softwares/amber22/amber.sh"
edgembar_path="/home/saikat/softwares/AMBER/edgembar.bashrc"
########################
source ${amber_path}
########################
for env in aq com; do
	for trail in t1 t2 t3 t4 t5 t6 t7 t8 t9 t10;do
		edgembar-amber2dats.py ${edge}/${env}/${trail}/*_ti.mdout
	done
done
cat <<EOF>> edgembar-example-writeinput.py
#!/usr/bin/env python3

from edgembar import DiscoverEdges
import os
from pathlib import Path

#
# The output directory (where the edge xml input files are to be written
#
odir = Path("${analysis}")
PWD = os.getcwd()
#
# The format string describing the directory structure.
# The {edge} {env} {stage} {trial} {traj} {ene} placeholders are used
# to extract substrings from the path; only the {edge} {traj} and {ene}
# are absolutely required.  The {env} placeholder must be either
# 'target' or 'reference', or you must supply the directory string
# with the target and reference optional arguments.
# If the {env} placeholder is missing, then
# 'complex' is assumed.
#
# Full example:
#    s = r"dats/{trial}/free_energy/{edge}_ambest/{env}/{stage}/efep_{traj}_{ene}.dat"
# Minimal example:
#    s = r"dats/{edge}/efep_{traj}_{ene}.dat"

s = PWD +"/{edge}/{env}/t{trial}/efep_{traj}_{ene}.dat"

exclusions=None
# exclusions=["trial1"]
edges = DiscoverEdges(s,
                      target='com',
                      reference='aq',
                      exclude_trials=exclusions)

#
# In some instances, one may have computed a stage with lambda values
# going in reverse order relative to the thermodynamic path that leads
# from the reactants to the products. We can reverse the order of the
# files to effectively negate the free energy of each state (essentially
# treating the lambda 0 state as the lambda 1 state).
#
#for edge in edges:
#    for trial in edge.GetAllTrials():
#        if trial.stage.name == "STAGE":
#            trial.reverse()

if not odir.is_dir():
    os.makedirs(odir)

for edge in edges:
    fname = odir / (edge.name + ".xml")
    edge.WriteXml( fname )
EOF
################
source "${edgembar_path}"
################
python3 edgembar-example-writeinput.py
cd ${analysis}
edgembar_omp ${edge}.xml
python3 ${edge}.py  ### it will generate ${edge}.html file.
