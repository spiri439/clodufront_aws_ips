#!/bin/bash

# Define variables
url="https://ip-ranges.amazonaws.com/ip-ranges.json"
json_file="/tmp/ip-ranges.json"
output_file="/etc/csf/aws.allow"
current_date=$(date +"%Y-%m-%d %H:%M:%S")

# Download the JSON file
curl -s $url -o $json_file

# Check if the download was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to download $url"
    exit 1
fi

# Filter the JSON file and extract CloudFront IPs, add the date comment
echo "# CloudFront IPs as of $current_date" > $output_file
jq -r '.prefixes[] | select(.region == "GLOBAL" and .service == "CLOUDFRONT") | .ip_prefix' < $json_file >> $output_file

# Check if jq command was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to process $json_file"
    exit 1
fi

echo "CloudFront IPs have been saved to $output_file"

# Restart CSF and LFD
csf -r

# Check if the restart was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to restart CSF and LFD"
    exit 1
fi

echo "CSF and LFD have been restarted successfully"

# Clean up
rm -f $json_file

exit 0
