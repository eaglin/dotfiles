#!/bin/bash

# Archivo temporal para almacenar estadísticas anteriores
STATS_FILE="/tmp/sketchybar_network_stats.tmp"

# Función para obtener bytes de interfaz principal
get_interface_stats() {
    # Buscar la interfaz activa principal (en0 o la que tenga más tráfico)
    local interface=$(route get default 2>/dev/null | grep interface | awk '{print $2}' | head -1)
    [ -z "$interface" ] && interface="en0"

    # Obtener estadísticas de la interfaz
    netstat -ibn | grep "$interface" | head -1 | awk '{print $7 " " $10}'
}

# Leer estadísticas actuales
CURRENT_STATS=$(get_interface_stats)
CURRENT_RX=$(echo $CURRENT_STATS | awk '{print $1}')
CURRENT_TX=$(echo $CURRENT_STATS | awk '{print $2}')

# Valores por defecto
DOWN=0
UP=0

# Si existe archivo previo, calcular diferencias
if [ -f "$STATS_FILE" ]; then
    PREV_STATS=$(cat "$STATS_FILE")
    PREV_RX=$(echo $PREV_STATS | awk '{print $1}')
    PREV_TX=$(echo $PREV_STATS | awk '{print $2}')

    # Calcular diferencias (bytes por segundo aproximadamente)
    DOWN=$((CURRENT_RX - PREV_RX))
    UP=$((CURRENT_TX - PREV_TX))

    # Evitar valores negativos por reinicios de contador
    [ $DOWN -lt 0 ] && DOWN=0
    [ $UP -lt 0 ] && UP=0
fi

# Guardar estadísticas actuales para la próxima ejecución
echo "$CURRENT_RX $CURRENT_TX" > "$STATS_FILE"

human_readable() {
    local bytes=$1

    if [ $bytes -ge 1073741824 ]; then
        printf "%3.0fG" $(echo "scale=0; $bytes / 1073741824" | bc)
    elif [ $bytes -ge 1048576 ]; then
        printf "%3.0fM" $(echo "scale=0; $bytes / 1048576" | bc)
    elif [ $bytes -ge 1024 ]; then
        printf "%3.0fK" $(echo "scale=0; $bytes / 1024" | bc)
    else
        printf "%3dB" $bytes
    fi
}

DOWN_FORMAT=$(human_readable $DOWN)
UP_FORMAT=$(human_readable $UP)

sketchybar --set network.down label="$DOWN_FORMAT/s" \
	       --set network.up   label="$UP_FORMAT/s"
