#!/bin/sh
#
# check-doc-coverage.sh
#
# Verifies that all markdown files in docs/ are referenced in their parent
# README.md file. Part of the documentation coverage check for the knowledge
# graph structure.
#
# Usage: ./scripts/check-doc-coverage.sh [docs_dir]
#        docs_dir defaults to ./docs
#
# Exit codes:
#   0 - All files are referenced
#   1 - Missing references found
#   2 - Usage or configuration error

set -e

# Configuration
DOCS_DIR="${1:-./docs}"
EXIT_CODE=0

# Verify docs directory exists
if [ ! -d "$DOCS_DIR" ]; then
    echo "Error: Documentation directory not found: $DOCS_DIR" >&2
    exit 2
fi

# Convert to absolute path for consistent handling
DOCS_DIR=$(cd "$DOCS_DIR" && pwd)

echo "Checking documentation coverage in: $DOCS_DIR"
echo "========================================"
echo ""

# Track counts
total_files=0
referenced_files=0
missing_files=0

# Find all markdown files except README.md files
# Use -name pattern to find .md files, exclude README.md
find "$DOCS_DIR" -name "*.md" -type f ! -name "README.md" | sort | while read -r filepath; do
    total_files=$((total_files + 1))

    # Get the directory containing this file
    dir=$(dirname "$filepath")

    # Get the filename without path
    filename=$(basename "$filepath")

    # Construct the path to the parent README.md
    readme="$dir/README.md"

    # Check if README.md exists in the same directory
    if [ ! -f "$readme" ]; then
        echo "WARN: No README.md in directory: $dir"
        echo "      Unreferenced file: $filename"
        missing_files=$((missing_files + 1))
        EXIT_CODE=1
        continue
    fi

    # Check if the filename is mentioned in the README.md
    # Use grep -q for quiet mode, -F for fixed string matching
    if grep -qF "$filename" "$readme"; then
        referenced_files=$((referenced_files + 1))
    else
        echo "MISSING: $filename"
        echo "      Not referenced in: $readme"
        missing_files=$((missing_files + 1))
        EXIT_CODE=1
    fi
done

# Note: Due to subshell in pipe, counters reset. Re-count for summary.
echo ""
echo "========================================"
echo "Coverage Summary"
echo "========================================"

# Re-count for accurate totals (pipe creates subshell)
total=$(find "$DOCS_DIR" -name "*.md" -type f ! -name "README.md" | wc -l | tr -d ' ')
missing=0

find "$DOCS_DIR" -name "*.md" -type f ! -name "README.md" | while read -r filepath; do
    dir=$(dirname "$filepath")
    filename=$(basename "$filepath")
    readme="$dir/README.md"

    if [ ! -f "$readme" ]; then
        missing=$((missing + 1))
    elif ! grep -qF "$filename" "$readme"; then
        missing=$((missing + 1))
    fi
done

# Final recount using a different approach to avoid subshell issues
missing_count=$(
    find "$DOCS_DIR" -name "*.md" -type f ! -name "README.md" | while read -r filepath; do
        dir=$(dirname "$filepath")
        filename=$(basename "$filepath")
        readme="$dir/README.md"

        if [ ! -f "$readme" ]; then
            echo "1"
        elif ! grep -qF "$filename" "$readme"; then
            echo "1"
        fi
    done | wc -l | tr -d ' '
)

referenced_count=$((total - missing_count))

echo "Total markdown files (excluding README.md): $total"
echo "Files referenced in parent README.md: $referenced_count"
echo "Files NOT referenced: $missing_count"
echo ""

if [ "$missing_count" -gt 0 ]; then
    echo "RESULT: Coverage incomplete - $missing_count file(s) missing references"
    exit 1
else
    echo "RESULT: Full coverage - all files are referenced"
    exit 0
fi
