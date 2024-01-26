#!/bin/bash

# Output file
output_file="A100_results_amber.dat"
temp_file="tmpl"

# Clear the output and temporary files if they already exist
rm "$output_file"

# Loop through files matching the pattern
for file in gpu_cuda_A100_*.out; do
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


