#!/bin/bash

# clean-assets.sh - Documentation Cleanup Script
#
# Updated on 2025-07-16 by @KemingHe
# 
# Purpose: Remove non-documentation files from dependency manager docs
# Configurable include/exclude lists for flexible cleanup
# Works on: temp-docs/ (during workflow) and src/assets/ (existing cleanup)
#
# Compatible with bash, zsh, GitHub Actions runner environments

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# =============================================================================
# CONFIGURATION: Include/Exclude Lists (exclude takes priority)
# =============================================================================

# Files to ALWAYS keep (include list)
INCLUDE_EXTENSIONS=("md" "rst")
INCLUDE_FILENAMES=("_metadata.yml")

# Files to ALWAYS remove (exclude list - higher priority)
# Note: PDFs removed because Tantivy cannot index binary files directly
# Note: PUML files reconsidered - they contain valuable architecture docs but aren't searchable
EXCLUDE_EXTENSIONS=("py" "js" "css" "html" "json" "yml" "yaml" "txt" "pdf" "png" "jpg" "jpeg" "svg" "ico" "gif" "csv" "puml" "dot" "in")
EXCLUDE_FILENAMES=("Makefile" "requirements.txt" "robots.txt" ".gitkeep")

# Special handling: files that match include but should be excluded anyway
FORCE_EXCLUDE_PATTERNS=("requirements.txt" "requirements-*.txt" "requirements-*.in")

# Color output for better UX (if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a file should be kept
should_keep_file() {
    local file_path="$1"
    local filename
    filename=$(basename "$file_path")
    
    # Extract extension properly (handle files without extensions)
    local extension=""
    if [[ "$filename" == *.* ]]; then
        extension="${filename##*.}"
    fi
    
    # 1. Force exclude patterns (highest priority)
    for pattern in "${FORCE_EXCLUDE_PATTERNS[@]}"; do
        # shellcheck disable=SC2053 # Intentional glob matching for patterns like "requirements-*.txt"
        if [[ "$filename" == $pattern ]]; then
            return 1  # Remove
        fi
    done
    
    # 2. Include filenames (exact match, overrides extension rules)
    for include_name in "${INCLUDE_FILENAMES[@]}"; do
        if [[ "$filename" == "$include_name" ]]; then
            return 0  # Keep
        fi
    done
    
    # 3. Exclude filenames (exact match)
    for exclude_name in "${EXCLUDE_FILENAMES[@]}"; do
        if [[ "$filename" == "$exclude_name" ]]; then
            return 1  # Remove
        fi
    done
    
    # 4. Check extensions only if file has an extension
    if [[ -n "$extension" ]]; then
        # 4a. Exclude extensions
        for exclude_ext in "${EXCLUDE_EXTENSIONS[@]}"; do
            if [[ "$extension" == "$exclude_ext" ]]; then
                return 1  # Remove
            fi
        done
        
        # 4b. Include extensions
        for include_ext in "${INCLUDE_EXTENSIONS[@]}"; do
            if [[ "$extension" == "$include_ext" ]]; then
                return 0  # Keep
            fi
        done
    fi
    
    # 5. Default behavior depends on whether we have include rules
    if [[ ${#INCLUDE_EXTENSIONS[@]} -eq 0 && ${#INCLUDE_FILENAMES[@]} -eq 0 ]]; then
        return 0  # No include rules = keep by default (blacklist mode)
    else
        return 1  # Has include rules = remove if not matched (whitelist mode)
    fi
}

# Function to clean a directory
clean_directory() {
    local target_dir="$1"
    local dir_name="$2"
    
    if [[ ! -d "$target_dir" ]]; then
        log_warning "Directory $target_dir does not exist, skipping"
        return 0
    fi
    
    log_info "Cleaning $dir_name: $target_dir"
    
    # Count files before cleanup
    local total_before
    total_before=$(find "$target_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    # Find and remove non-documentation files using configurable include/exclude lists
    local removed_count=0
    
    # Use find with modular file checking
    while IFS= read -r -d '' file; do
        # Use modular function to check if file should be kept
        if should_keep_file "$file"; then
            continue  # Keep this file
        fi
        
        # Remove the file
        rm -f "$file"
        ((removed_count++))
        log_info "Removed: ${file#"$target_dir"/}"
    done < <(find "$target_dir" -type f -print0 2>/dev/null)
    
    # Remove empty directories (but keep the main structure)
    find "$target_dir" -type d -empty -not -path "$target_dir" -delete 2>/dev/null || true
    
    local kept_count
    kept_count=$((total_before - removed_count))
    
    log_success "Cleanup complete for $dir_name:"
    log_success "  Files before: $total_before"
    log_success "  Files removed: $removed_count"
    log_success "  Files kept: $kept_count"
    log_success "  Space saved: $(echo "scale=1; $removed_count * 100 / $total_before" | bc -l 2>/dev/null || echo "N/A")%"
}

# Main execution
main() {
    log_info "Starting documentation cleanup process..."
    log_info "Include extensions: ${INCLUDE_EXTENSIONS[*]}"
    log_info "Include filenames: ${INCLUDE_FILENAMES[*]}"
    log_info "Exclude extensions: ${EXCLUDE_EXTENSIONS[*]}"
    log_info "All non-included files will be REMOVED"
    echo
    
    # Clean temp-docs directory (used during GitHub Actions workflow)
    if [[ -d "temp-docs" ]]; then
        clean_directory "temp-docs" "Workflow temp directory"
        echo
    fi
    
    # Clean existing src/assets directory
    if [[ -d "src/assets" ]]; then
        clean_directory "src/assets" "Assets directory"
        echo
    fi
    
    # If no directories found, show usage
    if [[ ! -d "temp-docs" && ! -d "src/assets" ]]; then
        log_warning "No target directories found (temp-docs/ or src/assets/)"
        log_info "Usage: Run this script from the project root directory"
        log_info "       It will clean temp-docs/ and/or src/assets/ if they exist"
        return 1
    fi
    
    log_success "Documentation cleanup completed successfully!"
    log_info "Only included file types remain: ${INCLUDE_EXTENSIONS[*]} and ${INCLUDE_FILENAMES[*]}"
}

# Check for required tools
if ! command -v find >/dev/null 2>&1; then
    log_error "Required tool 'find' not found"
    exit 1
fi

# Check if bc is available for percentage calculation (optional)
if ! command -v bc >/dev/null 2>&1; then
    log_warning "Tool 'bc' not found - percentage calculations will be skipped"
fi

# Run main function
main "$@" 
