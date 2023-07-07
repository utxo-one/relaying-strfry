#!/bin/bash

# Check if the comma-separated values are provided as an argument
if [ -z "$1" ]; then
  echo "Error: Comma-separated list of hex values is required."
  exit 1
fi

# Split the comma-separated values into an array
IFS=',' read -ra values <<< "$1"

# Create an empty associative array for the JSON output
declare -A json_array

# Iterate over the values and add them to the JSON array
for value in "${values[@]}"; do
  json_array["$value"]=true
done

# Convert the associative array to JSON
json_output=$(declare -p json_array)
json_output=${json_output#*=}

# Output the JSON to the whitelist.json file
echo "$json_output" > /home/ubuntu/relaying-strfry/whitelist.json