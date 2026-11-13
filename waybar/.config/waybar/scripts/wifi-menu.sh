#!/usr/bin/env bash
# Menú de wifi para Waybar (rofi + nmcli), aparece debajo de la barra.

THEME="$HOME/.config/waybar/scripts/wifi.rasi"
menu() { rofi -dmenu -i -theme "$THEME" "$@"; }

# Si el menú ya está abierto, un segundo clic lo cierra.
if pgrep -x rofi >/dev/null; then pkill -x rofi; exit 0; fi

notify() { notify-send -a "Wi-Fi" -i network-wireless "$1" "$2"; }

radio=$(nmcli -t radio wifi)
soft=$(rfkill list wlan | grep -c "Soft blocked: yes")
hard=$(rfkill list wlan | grep -c "Hard blocked: yes")

# Bloqueo por hardware (tecla/interruptor físico): no se puede quitar por software.
if (( hard > 0 )); then
    printf '󰅖  Cerrar\n' | menu -p "Wi-Fi" -mesg "Modo avión por hardware: pulsa la tecla de modo avión del teclado (Fn)" >/dev/null
    exit 0
fi

# Modo avión (rfkill) o Wi-Fi apagado: ofrecer encenderlo.
if (( soft > 0 )) || [[ $radio != "enabled" ]]; then
    msg="Wi-Fi apagado"; (( soft > 0 )) && msg="Modo avión activado"
    choice=$(printf '󰖩  Encender Wi-Fi\n' | menu -p "Wi-Fi" -mesg "$msg")
    if [[ $choice == *Encender* ]]; then
        rfkill unblock wlan
        nmcli radio wifi on
        notify "Wi-Fi encendido" "Buscando redes…"
    fi
    exit 0
fi

current=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2; exit}')

# Lista de redes: icono de señal, candado si es segura, marca si es la actual.
networks=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan auto | sort -t: -k1,1r -k2,2nr |
  awk -F: '$4 != "" && !seen[$4]++ {
      s=$2+0
      if      (s>=75) icon="󰤨"; else if (s>=50) icon="󰤥";
      else if (s>=25) icon="󰤢"; else            icon="󰤟";
      lock = ($3=="" || $3=="--") ? "  " : "󰌾 ";
      mark = ($1=="*") ? "  ✓" : "";
      printf "%s  %s %s%s\n", icon, lock, $4, mark
  }')

options="󰑐  Buscar de nuevo\n󰖪  Apagar Wi-Fi\n󰀝  Modo avión\n${networks}"
mesg="Conectado a: ${current:-ninguna}"

choice=$(printf "%b" "$options" | menu -p "Wi-Fi" -mesg "$mesg")
[[ -z $choice ]] && exit 0

case "$choice" in
    *"Buscar de nuevo")
        nmcli dev wifi rescan 2>/dev/null; sleep 2; exec "$0" ;;
    *"Apagar Wi-Fi")
        nmcli radio wifi off && notify "Wi-Fi apagado" "Clic en el Wi-Fi de la barra para encenderlo"; exit 0 ;;
    *"Modo avión")
        rfkill block all && notify "Modo avión activado" "Clic en el Wi-Fi de la barra para desactivarlo"; exit 0 ;;
esac

# Extraer el SSID: quitar icono, candado y la marca ✓
ssid=$(sed -E 's/^[^ ]+  (󰌾 |  ) //; s/  ✓$//' <<<"$choice")

if [[ $ssid == "$current" ]]; then
    act=$(printf '󰖪  Desconectar\n󰆴  Olvidar red\n' | menu -p "$ssid")
    case "$act" in
        *Desconectar) nmcli con down id "$ssid" && notify "Desconectado" "$ssid" ;;
        *Olvidar*)    nmcli con delete id "$ssid" && notify "Red olvidada" "$ssid" ;;
    esac
    exit 0
fi

# Red ya guardada: conectar directo.
if nmcli -t -f NAME con show | grep -Fxq "$ssid"; then
    if nmcli con up id "$ssid" >/dev/null 2>&1; then
        notify "Conectado" "$ssid"
    else
        notify "No se pudo conectar" "$ssid"
    fi
    exit 0
fi

# Red nueva: pedir contraseña si es segura.
if [[ $choice == *"󰌾"* ]]; then
    pass=$(menu -p "Contraseña" -password -mesg "$ssid" </dev/null)
    [[ -z $pass ]] && exit 0
    out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1)
else
    out=$(nmcli dev wifi connect "$ssid" 2>&1)
fi

if [[ $? -eq 0 ]]; then
    notify "Conectado" "$ssid"
else
    nmcli con delete id "$ssid" >/dev/null 2>&1   # no guardar una contraseña mala
    notify "No se pudo conectar" "$ssid: contraseña incorrecta o red fuera de alcance"
fi
