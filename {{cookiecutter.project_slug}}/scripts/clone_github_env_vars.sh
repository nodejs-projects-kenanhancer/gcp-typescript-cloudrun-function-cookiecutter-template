#!/bin/bash

# Check if required tools are installed
command -v gh >/dev/null 2>&1 || {
    echo "Error: GitHub CLI (gh) is required but not installed."
    exit 1
}
command -v jq >/dev/null 2>&1 || {
    echo "Error: jq is required but not installed."
    exit 1
}

# Function to display usage
usage() {
    echo "Usage: $0 --source <source_repo> --target <target_repo> --owner <owner> --envs <environments> [--update]"
    echo "Example: $0 --source gcp_shared_resources --target medallion_shared_resources --owner python-projects-kenanhancer --envs dev,preprod,prod"
    echo ""
    echo "Options:"
    echo "  --source <source_repo>   Source repository to copy variables from"
    echo "  --target <target_repo>   Target repository to copy variables to"
    echo "  --owner <owner>          GitHub organization or username"
    echo "  --envs <environments>    Comma-separated list of environments to copy"
    echo "  --update                 Update existing variables (optional, default: skip existing)"
    echo "  --help                   Display this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --source)
        SOURCE_REPO="$2"
        shift 2
        ;;
    --target)
        TARGET_REPO="$2"
        shift 2
        ;;
    --owner)
        OWNER="$2"
        shift 2
        ;;
    --envs)
        ENVIRONMENTS_INPUT="$2"
        shift 2
        ;;
    --update)
        update_existing=true
        shift
        ;;
    --help)
        usage
        ;;
    *)
        echo "Unknown argument: $1"
        usage
        ;;
    esac
done

# Check required parameters
if [ -z "$SOURCE_REPO" ] || [ -z "$TARGET_REPO" ] || [ -z "$OWNER" ] || [ -z "$ENVIRONMENTS_INPUT" ]; then
    echo "Error: Missing required parameters"
    usage
fi

# Convert comma-separated string to array
IFS=',' read -ra ENVIRONMENTS <<<"$ENVIRONMENTS_INPUT"

# Function to ensure environment exists
ensure_environment_exists() {
    local owner="$1"
    local repo="$2"
    local env_name="$3"

    echo "Ensuring environment $env_name exists in $owner/$repo..."

    # Try to create the environment (ignore if it already exists)
    gh api -X PUT "/repos/$owner/$repo/environments/$env_name" --silent || {
        echo "Failed to create environment $env_name in $owner/$repo"
        return 1
    }
    echo "Environment $env_name is ready"
}

# Function to clone variables for a specific environment
clone_environment_variables() {
    local owner="$1"
    local source_repo="$2"
    local target_repo="$3"
    local env_name="$4"

    echo "Copying variables for environment: $env_name"

    # Create a temporary directory for this environment
    TEMP_DIR=$(mktemp -d)

    # Get environment variables from source repo as JSON
    echo "Fetching variables from source..."
    gh api "repos/$owner/$source_repo/environments/$env_name/variables" >"$TEMP_DIR/vars.json"

    # Get existing variables in target environment
    echo "Fetching existing variables in target environment..."
    target_vars=$(gh api "repos/$owner/$target_repo/environments/$env_name/variables")

    # Extract just the variables array from the JSON response
    jq -r '.variables' "$TEMP_DIR/vars.json" >"$TEMP_DIR/variables_array.json"

    # Process each variable
    jq -c '.[]' "$TEMP_DIR/variables_array.json" | while read -r var; do
        name=$(echo "$var" | jq -r '.name')
        value=$(echo "$var" | jq -r '.value')

        # Check if variable exists in target environment
        if echo "$target_vars" | jq -e --arg name "$name" '.variables[] | select(.name==$name)' >/dev/null; then
            if [ "$update_existing" = true ]; then
                echo "Updating existing variable: $name"
                gh api --method PATCH "repos/$owner/$target_repo/environments/$env_name/variables/$name" \
                    -f value="$value" || echo "Failed to update $name"
            else
                echo "Skipping existing variable: $name"
            fi
        else
            echo "Creating new variable: $name"
            gh api --method POST "repos/$owner/$target_repo/environments/$env_name/variables" \
                -f name="$name" -f value="$value" || {
                echo "Failed to set $name"
                # If failed, try to create environment and retry
                if ensure_environment_exists "$owner" "$target_repo" "$env_name"; then
                    echo "Retrying to set variable $name..."
                    gh api --method POST "repos/$owner/$target_repo/environments/$env_name/variables" \
                        -f name="$name" -f value="$value" || echo "Failed to set $name again"
                fi
            }
        fi
    done

    # Clean up
    rm -rf "$TEMP_DIR"

    echo "Completed copying variables for $env_name environment"
    echo "----------------------------------------------------"
}

# Function to list secrets that need to be copied
list_environment_secrets() {
    local owner="$1"
    local source_repo="$2"
    local target_repo="$3"
    local env_name="$4"

    echo "Fetching secrets from $env_name environment in source repo..."
    source_secrets=$(gh secret list -e "$env_name" -R "$owner/$source_repo" --json name) || true

    echo "Fetching existing secrets in target environment..."
    target_secrets=$(gh secret list -e "$env_name" -R "$owner/$target_repo" --json name) || true

    if [ ! -z "$source_secrets" ]; then
        echo -e "\n=== Secrets that need to be manually copied for $env_name ==="
        echo "Please copy the following secrets from $env_name environment in source repo to target repo:"
        echo "$source_secrets" | jq -c '.[]' | while read -r secret; do
            name=$(echo $secret | jq -r '.name')

            # Check if secret already exists in target environment
            if echo "$target_secrets" | jq -e --arg name "$name" '.[] | select(.name==$name)' >/dev/null; then
                echo "✓ Secret $name already exists in target environment"
            else
                echo "→ Secret $name needs to be copied"
            fi
        done
        echo -e "===============================================\n"
    else
        echo "No secrets found in $env_name environment or no access to list them"
    fi
}

# Main execution
echo "Starting copy from $OWNER/$SOURCE_REPO to $OWNER/$TARGET_REPO"
echo "Environments to copy: ${ENVIRONMENTS[*]}"
echo "Update existing variables: ${update_existing:-false}"
echo "----------------------------------------------------"

# Loop through each environment
for ENV_NAME in "${ENVIRONMENTS[@]}"; do
    # Ensure target environment exists before starting
    if ensure_environment_exists "$OWNER" "$TARGET_REPO" "$ENV_NAME"; then
        clone_environment_variables "$OWNER" "$SOURCE_REPO" "$TARGET_REPO" "$ENV_NAME"
        list_environment_secrets "$OWNER" "$SOURCE_REPO" "$TARGET_REPO" "$ENV_NAME"
    else
        echo "Failed to set up target environment $ENV_NAME. Skipping."
    fi
done

echo "All environment variables have been copied successfully!"
