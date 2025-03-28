#!/bin/bash

# Validate SAM templates script (fixed counters)

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize counters
valid_count=0
invalid_count=0
total_processed=0

# Function to validate a template
validate_template() {
    local template_path=$1
    echo -e "${YELLOW}Validating: ${template_path}${NC}"
    
    # Run SAM validation
    if sam validate --lint --template "$template_path"; then
        echo -e "${GREEN}Validation passed: ${template_path}${NC}"
        ((valid_count++))
    else
        echo -e "${RED}Validation failed: ${template_path}${NC}"
        ((invalid_count++))
    fi
    
    ((total_processed++))
    echo "----------------------------------------"
}

# Main execution

# Change to the root project directory
cd "$(dirname "$0")/.." || exit 1

# Find files and process while avoiding subshell issues
while IFS= read -r -d '' template; do
    # Check if path is in Microservices directory or root templates
    if [[ "$template" == *"Microservices/"* ]] || 
       [[ "$template" == "./template.yml" ]] || 
       [[ "$template" == "./api.yml" ]]; then
        validate_template "$template"
    fi
done < <(find . -type f \( -name "template.yml" -o -name "api.yml" \) -print0)

# Summary report
echo "========================================"
echo -e "Validation complete:"
echo -e "${GREEN}Valid templates: ${valid_count}${NC}"
echo -e "${RED}Invalid templates: ${invalid_count}${NC}"
echo -e "Total processed: ${total_processed}"

# Exit with appropriate status
if [ $invalid_count -gt 0 ]; then
    exit 1
else
    exit 0
fi
