# Guardianes del cristal: cambios de esta entrega

## 1. HUD más amigable
- Vida mostrada con 5 corazones del asset `assets/ui/44_corazones_vida.png` (20 de vida cada uno).
  Cada corazón es un TextureProgressBar, así que con 10 de daño se ve medio corazón.
- Destello rojo en el panel de vida al recibir daño.
- Paneles con fondo azul y borde (mismos colores que el panel de diálogo).
- Contador de cristales con el ícono `assets/items/crystal.png`.
- Panel de misión centrado arriba.
- Archivos: `scenes/game_hud.tscn`, `scripts/game_hud.gd`.

## 2. Joystick y botones (escena MobileControls)
- Funciones completadas en `scripts/mobile_controls.gd`:
  - `is_inside_joystick()`: detecta si el toque cayó sobre el joystick.
  - `update_joystick()`: mueve la perilla sin salir del radio y calcula la dirección (con zona muerta).
  - `reset_joystick()`: devuelve la perilla al centro al soltar.
- El joystick presiona las acciones del Input Map (`move_left`, `move_right`, `move_up`, `move_down`)
  con la fuerza del arrastre, así `player.gd` funciona igual con teclado o con pantalla táctil.
- Botón de ataque, conectado a la acción `player_attack`.
- Botón de interacción, conectado a la acción `interact` (abre el diálogo con el NPC).
- Imágenes nuevas: `assets/ui/btn_attack*.png`, `assets/ui/btn_interact*.png`.
- Joystick abajo a la izquierda y botones abajo a la derecha (posición para jugar con dos pulgares).

## 3. Conexión con el main
- `MobileControls` agregado como instancia en `scenes/main.tscn`.
- `scripts/main.gd`: se quitó la referencia a `UI/HUD/CrystalLabel`, que no existía y daba error al arrancar.
- `scenes/dialogue_ui.tscn`: el panel de diálogo ahora va centrado abajo para no tapar los controles.
- `project.godot`: activado `emulate_touch_from_mouse` para probar el joystick con el mouse en la PC.

## Cómo probar en el celular (Android)
1. En Godot: Editor > Manage Export Templates > descargar las plantillas.
2. Activar la depuración USB en el teléfono y conectarlo por cable.
3. Pulsar el ícono de Android arriba a la derecha (Remote Deploy),
   o ir a Proyecto > Exportar > Android > Exportar APK e instalar el APK en el teléfono.
