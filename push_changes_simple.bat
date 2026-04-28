@echo off
setlocal

cd /d "%~dp0"
set "REPO_URL=https://github.com/poprwc/urbano106.git"
set "BRANCH=work"

if not exist ".git" (
  echo [ERROR] Esta carpeta no tiene .git
  pause
  exit /b 1
)

git remote get-url origin >nul 2>&1
if errorlevel 1 (
  git remote add origin "%REPO_URL%"
) else (
  git remote set-url origin "%REPO_URL%"
)

git add .
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Update app changes"
) else (
  echo [INFO] No hay cambios nuevos para commit.
)

git push -u origin "%BRANCH%"
if errorlevel 1 (
  echo [ERROR] No se pudo subir. Revisa login/permisos de GitHub.
  pause
  exit /b 1
)

echo [OK] Cambios subidos a %BRANCH%.
pause
exit /b 0
