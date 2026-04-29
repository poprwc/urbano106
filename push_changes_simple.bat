@echo off
setlocal

cd /d "%~dp0"
set "REPO_URL=https://github.com/poprwc/urbano106.git"
set "DEFAULT_BRANCH=main"

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

for /f "delims=" %%b in ('git branch --show-current 2^>nul') do set "BRANCH=%%b"
if not defined BRANCH set "BRANCH=%DEFAULT_BRANCH%"

git add .
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Update app changes"
) else (
  echo [INFO] No hay cambios nuevos para commit.
)

git push -u origin "%BRANCH%"
if errorlevel 1 (
  echo [ERROR] No se pudo subir a la rama %BRANCH%.
  echo [TIP] Prueba manual: git push -u origin %DEFAULT_BRANCH%
  pause
  exit /b 1
)

echo [OK] Cambios subidos a %BRANCH%.
pause
exit /b 0
