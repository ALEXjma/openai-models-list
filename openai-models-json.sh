#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Causes pipelines to fail on the first command that fails

# Check if API_KEY is set
if [[ -z "$API_KEY" ]]; then
  echo "Error: API_KEY environment variable is not set." >&2
  exit 1
fi

# Get models, select only the IDs from the 'data' array, sort them,
# and construct the final JSON using jq itself.
curl -sS -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $API_KEY" \
     https://api.openai.com/v1/models | \
jq --sort-keys '{models: [.data[].id | select(type == "string")] | sort}'

# Explanation of the jq command:
# curl -sS: Silent mode (-s) but show errors (-S)
# jq --sort-keys: Sort the keys in the final output object (optional, but nice)
# '{models: ... }': Create a JSON object with a single key "models".
# '[.data[].id | select(type == "string")]':
#   .data[]: Access each element in the 'data' array from the OpenAI response.
#   .id: Get the 'id' field from each element.
#   select(type == "string"): Ensure we only take IDs that are strings (handles potential nulls/errors).
#   []: Collect these selected IDs into a new array.
# '| sort': Sort the array of IDs alphabetically.
# The result of the [...] | sort part becomes the value for the "models" key.
