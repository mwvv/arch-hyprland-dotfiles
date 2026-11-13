#!/usr/bin/env bash
# Instala el rice: paquetes + enlaces con stow + ajustes de apariencia.
# Uso:  git clone https://github.com/mwvv/arch-hyprland-dotfiles ~/dotfiles && ~/dotfiles/install.sh
set -euo pipefail

DOTS="$(cd "$(dirname "$0")" && pwd)"
PKGS=(hypr waybar kitty fastfetch btop mako rofi swayosd gtk qt scripts)

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }

# 1. Paquetes
say "Instalando paquetes (pide tu contraseña de sudo)"
grep -vE '^\s*(#|$)' "$DOTS/packages.txt" | sudo pacman -S --needed --noconfirm -

# 2. Respaldar configs existentes que chocarían con stow
backup="$HOME/.config-backup-$(date +%F_%H-%M-%S)"
for pkg in "${PKGS[@]}"; do
  while IFS= read -r -d '' f; do
    rel="${f#"$DOTS/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e $target && ! -L $target ]]; then
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target" "$backup/$rel"
      say "Respaldado: ~/$rel"
    fi
  done < <(find "$DOTS/$pkg" -type f -print0)
done
[[ -d $backup ]] && say "Tus configs anteriores quedaron en $backup"

# 3. Enlazar
say "Enlazando configs con stow"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
stow -d "$DOTS" -t "$HOME" --restow "${PKGS[@]}"

# 4. Apariencia GTK
say "Aplicando tema oscuro, íconos y cursor"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
gsettings set org.gnome.desktop.interface cursor-theme capitaine-cursors
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
# Dolphin (KDE) no toma el esquema de colores por sí solo
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme GlassNeutro 2>/dev/null || true

# 5. Servicios
sudo systemctl enable --now NetworkManager power-profiles-daemon >/dev/null 2>&1 || true

say "Listo. Cierra sesión y entra a Hyprland."
