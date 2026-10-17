@echo off
rem Starts Diorama Room 01. Needs Godot 4.7 (standard build, not .NET).
rem Set GODOT to the Godot executable, or put it on PATH, or unzip it to %USERPROFILE%\Godot.
setlocal
if "%GODOT%"=="" if exist "%USERPROFILE%\Godot\Godot_v4.7.2-stable_win64.exe" set "GODOT=%USERPROFILE%\Godot\Godot_v4.7.2-stable_win64.exe"
if "%GODOT%"=="" set "GODOT=godot"
start "" "%GODOT%" --path "%~dp0."
