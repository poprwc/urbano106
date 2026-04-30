# urbano106

## Subir cambios rápido a GitHub (Windows)

Este repo incluye `push_to_github.bat` para automatizar el flujo básico:

1. Configura/corrige `origin` a `https://github.com/poprwc/urbano106.git`.
2. Hace `git add .`.
3. Crea commit si hay cambios (pide mensaje).
4. Hace `git push -u origin <rama>`.

Uso:

- Abre la carpeta del proyecto en Windows.
- Ejecuta `push_to_github.bat` con doble clic.
- Sigue los prompts de rama y mensaje de commit.


## Subida ultra simple (Windows)

Si quieres cero preguntas, usa `push_changes_simple.bat` (doble clic):

- Usa el repo `https://github.com/poprwc/urbano106.git`.
- Usa la rama actual detectada por Git (si no detecta, usa `main`).
- Hace `add`, commit automático (`Update app changes`) si detecta cambios y push.
