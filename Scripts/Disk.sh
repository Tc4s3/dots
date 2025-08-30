#!/bin/bash
echo "NV: $(df -h / | awk 'NR==2 {printf "%.0f/%.0fGB", $3, $2}')"
