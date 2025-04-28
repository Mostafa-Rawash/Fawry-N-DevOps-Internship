#!/bin/bash

# A mini version of the grep command

usage() {
    echo "Usage: $0 [-i] [-v] [-c] [-n] [--help] pattern file"
    echo "  -i: Ignore case"
    echo "  -v: Invert match"
    echo "  -c: Count matching lines"
    echo "  -n: Show line numbers for each match"
    echo "  --help: Display this help message"
    exit 1
}

ignore_case=false
invert_match=false
count_only=false
show_line_numbers=false

while getopts "ivcn-:" opt; do
    case $opt in
        i) ignore_case=true ;;
        v) invert_match=true ;;
        c) count_only=true ;;
        n) show_line_numbers=true ;;
        -)
            case $OPTARG in
                help) usage ;;
                *) echo "Invalid option: --$OPTARG" && usage ;;
            esac
            ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -lt 2 ]; then
    echo "Error: Missing search string or file."
    usage
fi

pattern=$1
file=$2

if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found!"
    exit 1
fi

# Prepare the pattern for case-insensitive matching if needed
if $ignore_case; then
    pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
fi

line_number=0
match_count=0

while IFS= read -r line; do
    line_number=$((line_number + 1))
    processed_line=$line

    # Convert line to lowercase if case-insensitive matching is enabled
    if $ignore_case; then
        processed_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    fi

    # Check if the line matches the pattern
    if [[ $processed_line == *"$pattern"* ]]; then
        is_match=true
    else
        is_match=false
    fi

    # Invert match if -v is enabled
    if $invert_match; then
        is_match=!$is_match
    fi

    if $is_match; then
        match_count=$((match_count + 1))
        if ! $count_only; then
            if $show_line_numbers; then
                echo "$line_number:$line"
            else
                echo "$line"
            fi
        fi
    fi
done < "$file"

if $count_only; then
    echo "$match_count"
fi