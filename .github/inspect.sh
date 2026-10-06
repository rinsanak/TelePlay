#!/usr/bin/env bash
# Prints source context for build errors into report/context.txt
F=$(find teleplay -name PlayerViewModel.kt | head -n 1)
echo "##### $F"
awk 'NR>=490 && NR<=575 {print NR": "$0}' "$F"
echo
echo "##### getServerUrl usages"
grep -rn "getServerUrl" teleplay --include=*.kt
