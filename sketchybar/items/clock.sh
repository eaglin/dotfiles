# Ruta del plugin
PLUGIN="$HOME/.config/sketchybar/plugins/clock.sh"

sketchybar --add item clock center \
  --set clock script="$PLUGIN" \
  update_freq=10 \
  click_script="open -a Calendar" \
  icon.padding_left=10 \
  label.padding_right=10 \
  background.color=$IRIS_TRANSPARENT \
  background.border_color=$IRIS \
  background.border_width=1 \
  background.height=30
