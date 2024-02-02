
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

3. To run multiple MD simulations using the AMBER 22 package, you can use the following [Bash script](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case/scripts/1_run.sh)

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
```
This Bash script will create output files named gpu_cuda_0_1.out, gpu_cuda_0_2.out, gpu_cuda_0_3.out, gpu_cuda_0_4.out, and gpu_cuda_0_5.out. You can view an example of what the output file names will look like by visiting this [URL](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case).

5. To obtain the performance data, you can utilize the following [Bash script](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case/scripts/2_extract_results.sh).
```bash
#!/bin/bash

# Output file
output_file="RTX 5000_results_amber.dat"
temp_file="tmpl"

# Clear the output and temporary files if they already exist
rm "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_2_*.out; do
    if [[ -f "$file" ]]; then
        # Calculate the line number for the last 10th line
        total_lines=$(wc -l < "$file")
        line_number=$((total_lines - 9))

        # Extracting the last 10th line from each file
        last_line=$(sed -n "${line_number}p" "$file")

        # Writing the results to the temporary file
        echo "$last_line" >> "$temp_file"
#        echo "" >> "$temp_file"
    fi
done

# Extract ns/day values and write them to the output file
grep "ns/day =" "$temp_file" | awk '{print $4}' > "$output_file"

## Optional: Remove temporary file
 rm "$temp_file"


echo "Extracted data saved to $output_file"
```
After executing the [Bash script](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case/scripts/2_extract_results.sh) above, your [benchmark data](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/AMBER-benchmark/benchmark_6n4o_pmemd/case/RTX_5000_results_amber.dat) will be ready. The unit of the data is ns/day.

To obtain benchmark data using the following software versions:
- Gromacs 23.3
- NAMD 3
- Openmm 8.1

Please follow the steps outlined below:

1. **Gromacs:**
   - You can find the Gromacs [input files](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/GROMACS-benchmark/GROMACS_inputs) and a bash script for performing [simulations](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/GROMACS-benchmark/benchmark_6n4o_gromacs/cerebro/scripts/1_run_benchmark.sh) and [extracting](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/GROMACS-benchmark/benchmark_6n4o_gromacs/cerebro/scripts/2_extract_results.sh) data.

2. **NAMD 3:**
   - Similarly, the NAMD 3 [input files](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/NAMD-benchmark/NAMD_inputs) and a bash script for performing [simulations](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/NAMD-benchmark/benchmark_6n4o_namd/case/scripts/1_run_namd3_bench.sh) and [extracting](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/NAMD-benchmark/benchmark_6n4o_namd/case/scripts/2_extract_results.sh) data are also available.

3. **Openmm 8.1:**
   - Additionally, you can find the Openmm [input files](https://github.com/NgFEP/NgFEP-assessment/tree/main/c-MD/OPENMM-benchmark/OPENMM_inputs) and a bash script for performing [simulations](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/OPENMM-benchmark/benchmark_6n4o_openmm/case/scripts/1_run_benchmark.sh) and [extracting](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/OPENMM-benchmark/benchmark_6n4o_openmm/case/scripts/2_extract_results.sh) data.


## Plot

We used the Python-based Jupyter-lab [notebook](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/plot/avg-sd.ipynb) to plot the data.

![Alt text](https://github.com/NgFEP/NgFEP-assessment/blob/main/c-MD/plot/combined_benchmarks.jpg)

You can make use of this notebook to plot your performance data.

```python

import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Define the list of file names for Amber and OpenMM
amber_filenames = [
    '../AMBER-benchmark/benchmark_6n4o_pmemd/sylvaner/GTX_1080_Ti_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/case/TITAN_V_results_amber.dat',
    #'../AMBER-benchmark/benchmark_6n4o_pmemd/case/RTX_5000_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/cerebro/RTX_6000_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/cerebro/GP100_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/cerebro/RTX_2080_Ti_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/rioja/RTX_3090_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/rioja/RTX_5000_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/rioja/RTX_A4500_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/tesla/RTX_4070_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/amarel/A100_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/amarel/P100_results_amber.dat',
    #'../AMBER-benchmark/benchmark_6n4o_pmemd/amarel/rtx_2080_ti_results_amber.dat',
    # '../AMBER-benchmark/benchmark_6n4o_pmemd/amarel/rtx_3090_results_amber.dat',
    '../AMBER-benchmark/benchmark_6n4o_pmemd/amarel/V100_results_amber.dat'    
]

openmm_filenames = [
    '../OPENMM-benchmark/benchmark_6n4o_openmm/sylvaner/GTX_1080_Ti_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/case/TITAN_V_results_openmm.dat',
    #'../OPENMM-benchmark/benchmark_6n4o_openmm/case/Quadro_RTX_5000_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/cerebro/RTX_6000_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/cerebro/GP100_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/cerebro/RTX_2080_Ti_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/rioja/RTX_3090_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/rioja/RTX_5000_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/rioja/RTX_A4500_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/tesla/RTX_4070_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/amarel/A100_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/amarel/P100_results_openmm.dat',
    #'../OPENMM-benchmark/benchmark_6n4o_openmm/amarel/RTX_2080_ti_results_openmm.dat',
    # '../OPENMM-benchmark/benchmark_6n4o_openmm/amarel/RTX_3090_results_openmm.dat',
    '../OPENMM-benchmark/benchmark_6n4o_openmm/amarel/V100_results_openmm.dat'  
]

namd_filenames = [
    '../NAMD-benchmark/benchmark_6n4o_namd/sylvaner/GTX_1080_Ti_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/case/TITAN_V_results_namd.dat',
    #'../NAMD-benchmark/benchmark_6n4o_namd/case/Quadro_RTX_5000_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/cerebro/RTX_6000_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/cerebro/GP100_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/cerebro/RTX_2080_Ti_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/rioja/RTX_3090_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/rioja/RTX_5000_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/rioja/RTX_A4500_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/tesla/RTX_4070_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/amarel/A100_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/amarel/P100_results_namd.dat',
    #'../NAMD-benchmark/benchmark_6n4o_namd/amarel/RTX_2080_ti_results_namd.dat',
    # '../NAMD-benchmark/benchmark_6n4o_openmm/amarel/RTX_3090_results_namd.dat',
    '../NAMD-benchmark/benchmark_6n4o_namd/amarel/V100_results_namd.dat'  
]

gromacs_filenames = [
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/sylvaner/GTX_1080_Ti_results_gromacs_4.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/case/TITAN_V_results_gromacs.dat',
    #'../GROMACS-benchmark/benchmark_6n4o_gromacs/case/Quadro_RTX_5000_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/cerebro/RTX_6000_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/cerebro/GP100_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/cerebro/RTX_2080_Ti_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/rioja/RTX_3090_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/rioja/RTX_5000_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/rioja/RTX_A4500_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/tesla/RTX_4070_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/amarel/A100_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/amarel/P100_results_gromacs.dat',
    #'../GROMACS-benchmark/benchmark_6n4o_gromacs/amarel/RTX_2080_Ti_results_gromacs.dat',
    # '../GROMACS-benchmark/benchmark_6n4o_gromacs/amarel/RTX_3090_results_gromacs.dat',
    '../GROMACS-benchmark/benchmark_6n4o_gromacs/amarel/V100_results_gromacs.dat'  
    
]

device = [
    'GTX_1080_Ti', 'TITAN_V', 'Quadro_RTX_6000', 'Quadro_GP100',
    'RTX_2080_Ti', 'RTX_3090', 'Quadro_RTX_5000', 'RTX_A4500', 'RTX_4070',
    'A100','P100',#'RTX_2080_Ti',#'RTX_3090',
    'V100'
]


# Existing code for filenames and device names...

# CUDA compatibility scores for each device
cuda_scores = {
    'GTX_1080_Ti': 6.1, 'TITAN_V': 7.0, 'Quadro_RTX_5000': 7.5, 
    'Quadro_RTX_6000': 7.5, 'Quadro_GP100': 6.0, 'RTX_2080_Ti': 7.5, 
    'RTX_3090': 8.6, 'RTX_A4500': 8.6, 'RTX_4070': 9.0, # Anticipated score for RTX_4070
    'A100': 8.0, 'P100': 6.0, 'V100': 7.0
}


# Initialize lists to hold the averages and standard deviations for Amber, OpenMM, NAMD, and GROMACS
amber_averages = []
amber_standard_deviations = []
openmm_averages = []
openmm_standard_deviations = []
namd_averages = []
namd_standard_deviations = []
gromacs_averages = []
gromacs_standard_deviations = []

# Loop through each file, calculate the average and standard deviation of the second column for Amber
for file in amber_filenames:
    # Check if file exists
    if not os.path.isfile(file):
        print(f"File {file} not found.")
        continue

    # Read the data from the file
    data = pd.read_csv(file, sep='\s+', header=None)
    second_column = data.iloc[:, 0]

    # Calculate average and standard deviation and append to Amber lists
    amber_averages.append(second_column.mean())
    amber_standard_deviations.append(second_column.std())

# Loop through each file, calculate the average and standard deviation of the second column for OpenMM
for file in openmm_filenames:
    # Check if file exists
    if not os.path.isfile(file):
        print(f"File {file} not found.")
        continue

    # Read the data from the file
    data = pd.read_csv(file, sep='\s+', header=None)
    second_column = data.iloc[:, 0]

    # Calculate average and standard deviation and append to OpenMM lists
    openmm_averages.append(second_column.mean())
    openmm_standard_deviations.append(second_column.std())

# Loop through each file, calculate the average and standard deviation of the second column for NAMD
for file in namd_filenames:
    # Check if file exists
    if not os.path.isfile(file):
        print(f"File {file} not found.")
        continue

    # Read the data from the file
    data = pd.read_csv(file, sep='\s+', header=None)
    second_column = data.iloc[:, 0]

    # Calculate average and standard deviation and append to NAMD lists
    namd_averages.append(second_column.mean())
    namd_standard_deviations.append(second_column.std())

# Loop through each file, calculate the average and standard deviation of the second column for GROMACS
for file in gromacs_filenames:
    # Check if file exists
    if not os.path.isfile(file):
        print(f"File {file} not found.")
        continue

    # Read the data from the file
    data = pd.read_csv(file, sep='\s+', header=None)
    second_column = data.iloc[:, 0]

    # Calculate average and standard deviation and append to GROMACS lists
    gromacs_averages.append(second_column.mean())
    gromacs_standard_deviations.append(second_column.std())

# Sort the data based on the increasing order of CUDA compatibility scores
sorted_indices = sorted(range(len(device)), key=lambda i: cuda_scores[device[i]])
device = [device[i] for i in sorted_indices]
amber_averages = [amber_averages[i] for i in sorted_indices]
amber_standard_deviations = [amber_standard_deviations[i] for i in sorted_indices]
openmm_averages = [openmm_averages[i] for i in sorted_indices]
openmm_standard_deviations = [openmm_standard_deviations[i] for i in sorted_indices]
namd_averages = [namd_averages[i] for i in sorted_indices]
namd_standard_deviations = [namd_standard_deviations[i] for i in sorted_indices]
gromacs_averages = [gromacs_averages[i] for i in sorted_indices]
gromacs_standard_deviations = [gromacs_standard_deviations[i] for i in sorted_indices]

# Create a single figure and plot data on the same plot
x_positions = np.arange(len(device))
width = 0.20

fig, ax = plt.subplots(figsize=(12, 6))
amber_bars = ax.bar(x_positions, amber_averages, width, label='AMBER_22', yerr=amber_standard_deviations, alpha=0.7, ecolor='black', capsize=6, color="blue")
openmm_bars = ax.bar(x_positions + width, openmm_averages, width, label='OPENMM_8_1', yerr=openmm_standard_deviations, alpha=0.7, ecolor='black', capsize=6, color="red")
namd_bars = ax.bar(x_positions + 2 * width, namd_averages, width, label='NAMD_3_0', yerr=namd_standard_deviations, alpha=0.7, ecolor='black', capsize=6, color="green")
gromacs_bars = ax.bar(x_positions + 3 * width, gromacs_averages, width, label='GROMACS_23_3', yerr=gromacs_standard_deviations, alpha=0.7, ecolor='black', capsize=6, color="magenta")

# print (amber_averages)
# print (amber_standard_deviations)

# print (namd_averages)
# print (namd_standard_deviations)

# print (gromacs_averages)
# print (gromacs_standard_deviations)

# print (openmm_averages)
# print (openmm_standard_deviations)

# Add labels and titles
ax.set_ylabel('ns/day')
ax.set_title('6N4O Benchmark c-MD Results')
ax.set_xticks(x_positions + 1.5 * width)
ax.set_xticklabels(device, rotation="vertical")
ax.set_yticks(np.arange(0, 81, 10))
ax.set_ylim(top=80, bottom=0)
ax.legend()

# Save the combined plot
plt.tight_layout()
plt.savefig('combined_benchmarks.jpg', dpi=450, bbox_inches='tight')

# Display the plot
plt.show()
```

To install jupyter-lab, simply follow the [link](https://jupyter.org/install). It will guide you through the installation process.
<<<<<<< HEAD
=======

## Authors
Contributors names and contact info
- [Saikat Pal](https://github.com/saikat0003)
>>>>>>> 0d081aa (modify readme file)

## Authors
Contributors names and contact info
- [Saikat Pal](https://github.com/saikat0003)
