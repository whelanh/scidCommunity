#!/bin/bash

# Script to backup original language files and replace them with .tcl.new.clean versions
# Usage: ./apply_cleaned_files.sh

# Language file prefixes (excluding 'serbian', only 'SerbCyr')
LANGUAGE_FILES=(
    "czech"
    "deutsch"
    "francais"
    "hungary"
    "italian"
    "chinese"
    "nederlan"
    "norsk"
    "polish"
    "portbr"
    "russian"
    "spanish"
    "swedish"
    "catalan"
    "suomi"
    "greek"
    "SerbCyr"
    "romanian"
    "japanese"
)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================================================"
echo "Language File Replacement Script"
echo "========================================================================"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

processed=0
skipped=0
backed_up=0

for prefix in "${LANGUAGE_FILES[@]}"; do
    original_file="${prefix}.tcl"
    cleaned_file="${prefix}.tcl.new.clean"
    backup_file="${prefix}.tcl.bak"
    
    echo "----------------------------------------------------------------------"
    echo "Processing: ${original_file}"
    
    # Check if cleaned file exists
    if [[ ! -f "$cleaned_file" ]]; then
        echo -e "${YELLOW}  Skipped: ${cleaned_file} does not exist${NC}"
        ((skipped++))
        continue
    fi
    
    # Check if original file exists
    if [[ ! -f "$original_file" ]]; then
        echo -e "${YELLOW}  Warning: ${original_file} does not exist (nothing to replace)${NC}"
        echo -e "${BLUE}  Info: ${cleaned_file} exists but has no original to replace${NC}"
        ((skipped++))
        continue
    fi
    
    # Create backup of original file
    echo -e "${BLUE}  Creating backup: ${original_file} -> ${backup_file}${NC}"
    cp "$original_file" "$backup_file"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}  Error: Failed to create backup of ${original_file}${NC}"
        ((skipped++))
        continue
    fi
    ((backed_up++))
    
    # Replace original with cleaned version
    echo -e "${GREEN}  Replacing: ${original_file} with ${cleaned_file}${NC}"
    cp "$cleaned_file" "$original_file"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}  Error: Failed to replace ${original_file}${NC}"
        echo -e "${YELLOW}  Restoring from backup...${NC}"
        cp "$backup_file" "$original_file"
        ((skipped++))
        continue
    fi
    
    echo -e "${GREEN}  Success: ${original_file} updated${NC}"
    ((processed++))
done

echo ""
echo "========================================================================"
echo "SUMMARY"
echo "========================================================================"
echo -e "${GREEN}Files successfully processed: ${processed}${NC}"
echo -e "${BLUE}Files backed up: ${backed_up}${NC}"
echo -e "${YELLOW}Files skipped: ${skipped}${NC}"
echo ""

if [[ $backed_up -gt 0 ]]; then
    echo "Backup files created with .bak extension"
    echo "To restore a backup, use: cp <filename>.tcl.bak <filename>.tcl"
fi

echo "========================================================================"
