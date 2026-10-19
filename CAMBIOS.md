# Guardianes del cristal: cambios de esta entrega

## 1. HUD más amigable
- Vida mostrada con 5 corazones del asset `assets/ui/44_corazones_vida.png` (20 de vida cada uno).
  Cada corazón es un TextureProgressBar, así que con 10 de daño se ve medio corazón.
- Destello rojo en el panel de vida al recibir daño.
- Paneles con fondo azul y borde (mismos colores que el panel de diálogo).
- Contador de cristales con el ícono `assets/items/crystal.png`.
- Panel de misión centrado arriba.
- Archivos: `scenes/game_hud.tscn`, `scripts/game_hud.gd`.

## 2. Joystick flotante y botones (escena MobileControls)
- El joystick ahora es **flotante**: aparece donde se pone el dedo dentro de la zona
  izquierda inferior de la pantalla, y vuelve a su lugar al soltar.
- Funciones en `scripts/mobile_controls.gd`:
  - `is_inside_joystick()`: revisa si el toque cayó dentro de la zona táctil del joystick.
  - `update_joystick()`: mueve la perilla sin salir del aro y calcula la dirección;
    la zona muerta se reescala para que el movimiento arranque suave.
  - `reset_joystick()`: regresa el aro y la perilla, y suelta las acciones de movimiento.
- La dirección se reparte entre `move_left`, `move_right`, `move_up` y `move_down`
  con la fuerza del arrastre, así `player.gd` funciona igual con teclado o pantalla táctil.
- Señal `direction_changed` por si otra escena necesita saber hacia dónde se mueve.
- Estilo dorado; el joystick se ve semitransparente cuando no se está usando.
- Botones de hablar (`interact`) y atacar (`player_attack`) apilados a la derecha.

## 3. Conexión con el main
- `MobileControls` agregado como instancia en `scenes/main.tscn`.
- `scripts/main.gd`: se quitó la referencia a `UI/HUD/CrystalLabel`, que no existía y daba error al arrancar.
- `scenes/dialogue_ui.tscn`: el panel de diálogo ahora va centrado abajo para no tapar los controles.
- `project.godot`: activado `emulate_touch_from_mouse` para probar el joystick con el mouse en la PC.

## 4. Reiniciar al morir
- Al morir sale la pantalla "¡Has caído!" (`scenes/game_over.tscn`, `scripts/game_over.gd`)
  y el juego se pausa.
- Botón Reiniciar (o tecla E / Enter) recarga el nivel.
- `QuestManager.reset_quest()` deja la misión como al inicio.

## Cómo probar en el celular (Android)
1. En Godot: Editor > Manage Export Templates > descargar las plantillas.
2. Activar la depuración USB en el teléfono y conectarlo por cable.
3. Pulsar el ícono de Android arriba a la derecha (Remote Deploy),
   o ir a Proyecto > Exportar > Android > Exportar APK e instalar el APK en el teléfono.
