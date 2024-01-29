#!/bin/bash

# Output file
output_file="TITAN_V_results_openmm.dat"

# Clear the output file if it already exists
> "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_0_*.out; do
    if [[ -f "$file" ]]; then
        # Extracting the first and last line from each file
        first_line=$(head -n 1 "$file")
        last_line=$(tail -n 1 "$file")

        # Writing the results to the output file
        echo "File: $file" >> "tmpl"
        echo "First Line: $first_line" >> "tmpl"
        echo "Last Line: $last_line" >> "tmpl"
        echo "" >> "tmpl"
    fi
done

# Extract ns/day values and write them to the output file
grep "Benchmark time" "tmpl" | awk '{print $5}' > "$output_file"
rm tmpl

# Display a message when done
echo "Extracted data saved to $output_file"

