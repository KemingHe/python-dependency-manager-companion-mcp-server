#!/bin/bash

# clean-assets.sh - Documentation Cleanup Script
#
# Updated on 2025-07-16 by @KemingHe
# 
# Purpose: Remove non-documentation files from dependency manager docs
# Simple and safe approach using find with -delete
# Works on: temp-docs/ (during workflow) and src/assets/ (existing cleanup)

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Convert comma-separated strings to arrays for easier processing.
INCLUDE_EXTENSIONS="md,rst"
INCLUDE_FILENAMES="_metadata.json"

# --- Logging ---
echo "[INFO] Starting documentation cleanup process..."
echo "[INFO] Include extensions: ${INCLUDE_EXTENSIONS}"
echo "[INFO] Include filenames: ${INCLUDE_FILENAMES}"
echo "[INFO] All non-included files will be REMOVED"
echo ""

# Function to clean a directory using simple find approach
clean_directory_simple() {
    local target_dir="$1"
    local dir_name="$2"
    
    # Check if the target directory exists. If not, there's nothing to do.
    if [ ! -d "$target_dir" ]; then
        echo "[WARN] Directory '$target_dir' not found. Skipping cleanup."
        return 0
    fi
    
    echo "[INFO] Cleaning $dir_name: $target_dir"
    
    # Count files before cleanup
    local total_before
    total_before=$(find "$target_dir" -type f 2>/dev/null | wc -l | tr -d ' ') || total_before=0
    
    # Build the find command to locate all files that should be deleted
    # We want to find all files that DO NOT match our inclusion criteria
    local find_cmd="find \"$target_dir\" -type f"
    
    # 1. Handle included filenames (exact matches to keep)
    IFS=',' read -ra DONT_DELETE_FILENAMES <<< "$INCLUDE_FILENAMES"
    for filename in "${DONT_DELETE_FILENAMES[@]}"; do
        find_cmd+=" -not -name '$filename'"
    done
    
    # 2. Handle included extensions (extensions to keep)
    IFS=',' read -ra DONT_DELETE_EXTS <<< "$INCLUDE_EXTENSIONS"
    for ext in "${DONT_DELETE_EXTS[@]}"; do
        find_cmd+=" -not -name '*.$ext'"
    done
    
    # Execute the find command and delete the files found
    # The '|| true' ensures that even if find fails, it won't stop the script
    echo "[INFO] Finding and deleting non-essential files..."
    eval "$find_cmd" -delete || true
    
    # Count files after cleanup
    local total_after
    total_after=$(find "$target_dir" -type f 2>/dev/null | wc -l | tr -d ' ') || total_after=0
    
    # Calculate removed count and percentage
    local removed_count=$((total_before - total_after))
    local percentage=0
    if [ "$total_before" -gt 0 ]; then
        percentage=$(( (removed_count * 100) / total_before ))
    fi
    
    echo "[SUCCESS] Cleanup complete for $dir_name:"
    echo "[SUCCESS]   Files before: $total_before"
    echo "[SUCCESS]   Files removed: $removed_count"
    echo "[SUCCESS]   Files kept: $total_after"
    echo "[SUCCESS]   Space saved: ${percentage}%"
}

# Main execution
main() {
    # Clean temp-docs directory (used during GitHub Actions workflow)
    if [ -d "temp-docs" ]; then
        clean_directory_simple "temp-docs" "Workflow temp directory"
        echo ""
    fi
    
    # Clean existing src/assets directory
    if [ -d "src/assets" ]; then
        clean_directory_simple "src/assets" "Assets directory"
        echo ""
    fi
    
    # If no directories found, show usage
    if [ ! -d "temp-docs" ] && [ ! -d "src/assets" ]; then
        echo "[WARN] No target directories found (temp-docs/ or src/assets/)"
        echo "[INFO] Usage: Run this script from the project root directory"
        echo "[INFO]        It will clean temp-docs/ and/or src/assets/ if they exist"
        exit 0
    fi
    
    echo "[SUCCESS] Documentation cleanup completed successfully!"
    echo "[INFO] Only included file types remain: ${INCLUDE_EXTENSIONS} and ${INCLUDE_FILENAMES}"
}

# Run main function
main "$@" 
