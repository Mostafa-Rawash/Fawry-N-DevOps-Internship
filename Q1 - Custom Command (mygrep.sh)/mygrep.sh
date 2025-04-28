#!/bin/bash

# A mini version of the grep command

usage() {
    echo "Usage: $0 [-v] [-n] [--help] pattern file"
    echo "  -v: Invert match"
    echo "  -n: Show line numbers for each match"
    echo "  --help: Display this help message"
    exit 1
}

invert_match=false
show_line_numbers=false

while getopts "vn-:" opt; do
    case $opt in
        v) invert_match=true ;;
        n) show_line_numbers=true ;;
        h) usage ;;
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

# Convert the pattern to lowercase for case-insensitive matching
pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')

line_number=0

while IFS= read -r line; do
    line_number=$((line_number + 1))

    # Convert the line to lowercase for case-insensitive matching
    processed_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

    # Check if the line matches the pattern
    if [[ $processed_line == *"$pattern"* ]]; then
        is_match=true
    else
        is_match=false
    fi

    # Invert match if -v is enabled
    if $invert_match; then
        if $is_match; then
            is_match=false
        else
            is_match=true
        fi
    fi

    if $is_match; then
        if $show_line_numbers; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"