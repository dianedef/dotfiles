@echo off
where yazi.exe >nul 2>nul
if errorlevel 1 (
  echo Yazi is not installed. Rerun the Dotfiles Windows bootstrap with -ConfigureTools.
  exit /b 1
)
yazi.exe %*
