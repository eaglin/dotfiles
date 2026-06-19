#!/bin/bash
# Memory used %: active + wired + compressed (excludes inactive/cached pages)
read -r active inactive wired compressed psize <<EOF
$(vm_stat | awk '
  /Pages active/                 { gsub(/\./, ""); a=$3 }
  /Pages inactive/               { gsub(/\./, ""); i=$3 }
  /Pages wired down/             { gsub(/\./, ""); w=$4 }
  /Pages occupied by compressor/ { gsub(/\./, ""); c=$5 }
  /page size of/                 { gsub(/[^0-9]/, ""); p=$NF }
  END { print a, i, w, c, p }
')
EOF

TOTAL=$(sysctl -n hw.memsize)
USED=$(( (active + wired + compressed) * psize ))
PCT=$(( USED * 100 / TOTAL ))
sketchybar --set memory label="${PCT}%"
