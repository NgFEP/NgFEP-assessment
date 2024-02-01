
# Benchmarks for Molecular Dynamics Simulations with Popular Software Applications on different GPU Cards

This GitHub repository provides a comprehensive set of benchmarks for molecular dynamics simulations using conventional MD (c-MD) and Free Energy Perturbations /Thermodynamic Integration (FEP/TI) on different GPU cards with popular software applications such as AMBER 22, Gromacs 23.3, NAMD 3, and OpenMM 8.1. The benchmarks are designed to evaluate the performance of various software applications and GPU cards for molecular dynamics simulations. The repository includes detailed documentation on how to run the benchmarks and how to interpret the results. This benchmarking suite can be helpful for researchers in selecting the most suitable software and hardware for their particular research needs.


## Installation

To install AMBER 22, Gromacs 23.3, NAMD 3, and OpenMM 8.1 on different clusters, follow the respective installation instructions provided below:

**AMBER 22:**

Visit the [AMBER installation](https://ambermd.org/Installation.php)
- Follow the installation instructions specific to your cluster and operating system.
- Make sure to configure AMBER according to your requirements and available resources.

**Gromacs 23.3:**

Visit the [Gromacs documentation](https://manual.gromacs.org/documentation/current/install-guide/index.html)
- Navigate to the installation guide that matches your cluster and operating system.
- Follow the step-by-step instructions provided to install Gromacs.
Ensure that you configure Gromacs to utilize the cluster's hardware resources efficiently.

**NAMD 3:**

Go to the [NAMD](https://www.ks.uiuc.edu/Research/namd/alpha/3.0alpha/)
- Download the NAMD 3 version compatible with your cluster and operating system.
- Follow the installation instructions provided in the NAMD documentation.
- Make any necessary configuration changes to optimize NAMD for your cluster's resources.

**OpenMM 8.1:**

Access the [OpenMM user guide](http://docs.openmm.org/latest/userguide/application/01_getting_started.html#installing-openmm)
- Locate the section on installing OpenMM 8.1.
- Follow the installation steps tailored to your cluster and platform.
- Ensure that you set up OpenMM to make the best use of your cluster's capabilities.

Please note that installation procedures may vary depending on your cluster's specifications and your user privileges. Make sure to consult with your cluster administrator if you encounter any issues or require assistance with cluster-specific configurations during the installation process.

## c-MD Benchmark

To perform the c-MD benchmark using the AMBER 22 package, we used the complex of human Argonaute2 with miR-122 (PDB ID: 6N40) which was previously used by [MDbench](https://mdbench.ace-net.ca/mdbench/datasets/). you will need to download the required input files from the provided [GitHub repository](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/AMBER-benchmark/AMBER_inputs). Here are the steps to download these files:
1. In the [repository](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/AMBER-benchmark/AMBER_inputs), you will find three required input files:
   - `pmemd_prod.in`: This is the input file for running molecular dynamics simulations using the AMBER package.
   - `prmtop.parm7`: This file contains the topology information for your system.
   - `restart.rst7`: This file contains the initial coordinates and velocities for your simulation.

2. To download each of these files, follow these steps:
   - Click on the file's name to view its contents.
   - On the file's page, click the "Download" button to save the file to your local machine.

For multiple MD simulations run using AMBER 22 package you can use this following [scripts](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case/scripts)

```bash
#!/bin/bash

# Loop over the CUDA_VISIBLE_DEVICES values
for device in {0..2}; do
  # Loop over the output file indices
  for index in {1..5}; do
    # Set CUDA_VISIBLE_DEVICES
    export CUDA_VISIBLE_DEVICES=$device
    outfile="gpu_cuda_${device}_${index}.out"

    # Run the pmemd.cuda command with the specified output file
    pmemd.cuda -O -i pmemd_prod.in -p prmtop.parm7 -c restart.rst7 -o $outfile

  done
done


