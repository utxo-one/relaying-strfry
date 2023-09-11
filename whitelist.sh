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
json_output="{"
for key in "${!json_array[@]}"; do
  json_output+="\"$key\": ${json_array[$key]},"
done
json_output=${json_output%,*} # Remove the trailing comma
json_output+="}"

# Output the JSON to the whitelist.json file
echo "$json_output" > /var/lib/strfry/whitelist.json
