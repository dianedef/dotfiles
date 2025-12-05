#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

!a::

Run telmacro
Return

MouseMove X, Y, 2


SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
MouseMove, 634, 400, 2
sleep 100
MouseMove, 634, 400, 2
sleep 100
MouseMove, 634, 400, 2
sleep 100
Click, up
			
sleep 15
MouseMove, 625, 450, 2
sleep 100
MouseMove, 625, 450, 2
Click, down	
Click, up
return