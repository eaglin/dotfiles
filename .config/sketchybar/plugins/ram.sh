#!/usr/bin/env bash
#ram.sh

sketchybar -m --set "memory" label="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5"%") }')%"
