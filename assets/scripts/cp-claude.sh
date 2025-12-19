#!/bin/bash

# Configuration
PROXY_URL="http://localhost:8317"
API_KEY="sk-dummy"

# Export environment variables for Claude Code
export ANTHROPIC_BASE_URL="$PROXY_URL"
export ANTHROPIC_API_KEY="$API_KEY"

# If arguments are provided, pass them directly to claude
if [ "$#" -gt 0 ]; then
    exec claude "$@"
fi

# Interactive Mode: Fetch and select models
echo "🔍 Fetching available models..."

# Fetch models using curl
RESPONSE=$(curl -s -H "Authorization: Bearer $API_KEY" "$PROXY_URL/v1/models")

# Check if curl failed
if [ $? -ne 0 ]; then
    echo "❌ Failed to connect to proxy at $PROXY_URL"
    echo "Is the server running? Try 'cp-start'"
    exit 1
fi

# Parse models using python3 (safer than expecting jq everywhere, although we checked jq exists)
# We use python3 to ensure compatibility even if jq is missing on some user systems
MODELS=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data:
        for model in data['data']:
            print(model['id'])
    else:
        print('ERROR: Invalid JSON format')
except Exception as e:
    print(f'ERROR: {e}')
")

if [[ "$MODELS" == ERROR* ]]; then
    echo "❌ Failed to parse models."
    echo "Response: $RESPONSE"
    exit 1
fi

# Convert to array
MODEL_ARRAY=($MODELS)

if [ ${#MODEL_ARRAY[@]} -eq 0 ]; then
    echo "❌ No models found."
    exit 1
fi

echo "🤖 Available Models:"
i=1
for model in "${MODEL_ARRAY[@]}"; do
    echo "  $i) $model"
    ((i++))
done

echo ""
read -p "Select model (1-${#MODEL_ARRAY[@]}): " selection

if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#MODEL_ARRAY[@]}" ]; then
    SELECTED_MODEL="${MODEL_ARRAY[$((selection-1))]}"
    echo ""
    echo "🚀 Launching Claude Code with model: $SELECTED_MODEL"
    echo "   (Env: ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL)"
    echo ""
    exec claude --model "$SELECTED_MODEL"
else
    echo "❌ Invalid selection."
    exit 1
fi
