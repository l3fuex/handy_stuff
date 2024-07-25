#!/bin/bash

# Scan cisco backups to retrieve interface information based on search pattern.

# Check for arguments
if [ "$#" -eq 0 ]; then
  echo "Please specify a search pattern"
  exit
fi

# Print help
if [ "$1" = "-h" -o "$1" = "--help" ]; then
  echo "Usage: cisco-search <search pattern>"
  exit
fi

# Path to cisco configs
file="/tmp/cisco-search/*"

# AWK script in heredoc
awk -v search_pattern="$1" -f- $file << 'EOF'
BEGIN {
  RS = "!\n"
  IGNORECASE = 1
}

FNR == 2 {
  print_heading = 1
  n=split (FILENAME, tmp, "/")
  split (tmp[n], name, "_")
  separator = sprintf("%*s", length(name[1])+6, "")
  gsub(/ /, "~", separator)
}

FNR > 1 {
  if (match($0, search_pattern) && print_heading) {
    print separator
    print ">> " name[1] " <<"
    print separator
    print_heading = 0
  }

  if (match($0, search_pattern)) {
    sub(/!$/, "", $0)
    print
  }
}
EOF
