#!/bin/bash
# Disk usage % of the root volume (works on any APFS layout, no hardcoded disk id)
sketchybar --set disk label="$(df -H / | tail -1 | awk '{ print $5 }')"
