#!/bin/sh
##How To Install ACPYPE
conda install -c conda-forge acpype -y

## usage of ACPYPE
#conda activate acpype
echo "Activating conda environment"
eval "$($(which conda) 'shell.bash' 'hook')"
conda activate acpype
### for help 
acpype -h

#####################################################################

## How To Install pmx
# this environment will contain only the packages necessary to run the tutorial
conda create -n pmx python=3.7

# activate the environment
conda activate pmx

# install several required packages
conda install -y numpy matplotlib scipy pip pandas
conda install -c rdkit rdkit -y 
pip install jupyterlab

# Now let's download pmx
git clone https://github.com/deGrootLab/pmx
cd pmx

# we will use "develop" branch of the pmx
git checkout develop

# finally, install pmx
pip install .

## usage of pmx
#conda activate acpype
echo "Activating conda environment"
eval "$($(which conda) 'shell.bash' 'hook')"
conda activate pmx

#pmx help
pmx -h

