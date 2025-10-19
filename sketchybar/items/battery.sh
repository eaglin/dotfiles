# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/battery.sh"

sketchybar --add item battery right \
  --set battery script="$PLUGIN" \
                update_freq=120 \
                updates=on \
                icon.color=$GOLD \
                label.color=$TEXT
