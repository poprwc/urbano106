@echo off
setlocal

REM Ejecutar siempre desde la carpeta donde vive este .bat
cd /d "%~dp0"

set "REPO_URL=https://github.com/poprwc/urbano106.git"
set "DEFAULT_BRANCH=main"

echo.
echo ===== Urbano106 - Subir cambios a GitHub =====

REM Verifica que sea un repositorio Git
if not exist ".git" (
  echo [ERROR] Esta carpeta no contiene .git
  echo Abre este .bat dentro de la carpeta correcta del proyecto.
  pause
  exit /b 1
)

REM Configura o corrige origin
for /f "delims=" %%r in ('git remote get-url origin 2^>nul') do set "CURRENT_ORIGIN=%%r"
if not defined CURRENT_ORIGIN (
  git remote add origin "%REPO_URL%"
  if errorlevel 1 goto :fail
  echo [OK] Remote origin agregado: %REPO_URL%
) else (
  if /i not "%CURRENT_ORIGIN%"=="%REPO_URL%" (
    git remote set-url origin "%REPO_URL%"
    if errorlevel 1 goto :fail
    echo [OK] Remote origin actualizado: %REPO_URL%
  ) else (
    echo [OK] Remote origin ya estaba configurado.
  )
)

echo.
set /p BRANCH=Rama a subir (Enter para %DEFAULT_BRANCH%): 
if "%BRANCH%"=="" set "BRANCH=%DEFAULT_BRANCH%"

echo.
set /p COMMIT_MSG=Mensaje de commit (Enter para mensaje por defecto): 
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Update project files"

echo.
git add .
if errorlevel 1 goto :fail

git diff --cached --quiet
if not errorlevel 1 (
  echo [INFO] No hay cambios para commitear.
  goto :push
)

git commit -m "%COMMIT_MSG%"
if errorlevel 1 goto :fail

:push
echo.
git push -u origin "%BRANCH%"
if errorlevel 1 goto :fail

echo.
echo [OK] Cambios subidos correctamente a %BRANCH%.
pause
exit /b 0

:fail
echo.
echo [ERROR] Ocurrio un problema durante el proceso.
pause
exit /b 1
