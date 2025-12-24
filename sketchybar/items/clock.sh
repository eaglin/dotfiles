# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/clock.sh"

sketchybar --add item clock center \
  --set clock script="$PLUGIN" \
  update_freq=10 \
  click_script="open -a Calendar" \
  padding_left=0 \
  icon.padding_left=10 \
  label.padding_right=10 \
  icon.color="$SUBTEXT0" \
  background.color=$SURFACE0 \
  background.border_color=$MAUVE \
  background.corner_radius=6 \
  background.height=24
