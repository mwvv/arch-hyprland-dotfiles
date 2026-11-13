# arch-hyprland-dotfiles

Rice de Hyprland en Arch Linux con estilo *glass* (vidrio esmerilado).

Hyprland · Waybar · Rofi · Kitty · Mako · Hyprlock · Hypridle · SwayOSD · Fastfetch

## Instalación

```bash
git clone https://github.com/mwvv/arch-hyprland-dotfiles ~/dotfiles
~/dotfiles/install.sh
```

El script instala los paquetes de `packages.txt`, respalda tus configs actuales y enlaza todo con `stow`.

## Atajos

| Atajo | Acción |
|---|---|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + R` | Lanzador de apps |
| `SUPER + E` | Archivos (Dolphin) |
| `SUPER + C` | Cerrar ventana |
| `SUPER + F` | Maximizar |
| `SUPER + SHIFT + V` | Ventana flotante |
| `SUPER + flechas` | Mover el foco |
| `SUPER + SHIFT + flechas` | Mover ventana |
| `SUPER + CTRL + flechas` | Redimensionar ventana |
| `SUPER + 1..0` | Ir al workspace |
| `SUPER + SHIFT + 1..0` | Mandar ventana al workspace |
| `SUPER + V` | Historial del portapapeles |
| `SUPER + SHIFT + S` | Captura de un área (copia + aviso, clic para editar) |
| `SUPER + SHIFT + A` | Captura y editar con Satty |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + M` | Menú de apagado |
| `SUPER + SHIFT + T` | Cambiar tema de color (neutro / Catppuccin / cálido) |
| `SUPER + W` | Cambiar fondo de pantalla (fondos en `hypr/.config/hypr/wallpapers/`) |

## Waybar

- **Wifi:** clic → menú de redes · clic derecho → `nmtui`
- **Volumen:** clic → silenciar · clic derecho → `pavucontrol` · rueda → subir/bajar
- **Brillo:** rueda → subir/bajar
- **Reloj:** pasar el mouse → calendario · clic → fecha completa · clic derecho → luz nocturna
- **Rayo:** clic → cambiar perfil de energía
- **Botón de apagado:** menú de apagado

## Estructura

Cada carpeta es un paquete de `stow` que replica la ruta desde `~`:

```
hypr/      → ~/.config/hypr      (Hyprland, hyprlock, hypridle, hyprpaper, hyprsunset, fondo)
waybar/    → ~/.config/waybar    (barra + menú de wifi)
rofi/      → ~/.config/rofi      (lanzador, menú de apagado, colores compartidos)
kitty/  mako/  swayosd/  fastfetch/  btop/  gtk/  qt/
scripts/   → ~/.local/bin        (powermenu, clipboard-menu, screenshot, rice-theme…)
```
