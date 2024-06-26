﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
#if (Vim.IsVimGroup() && WinActive("ahk_class TElWind"))
; Disable
^+j::
^m::
^k::
Return

; Remap
^+!j::
  Send ^+j  ; shift position in outstanding queue
  Vim.State.SetMode("Insert"), Vim.State.BackToNormal := 1
return

^+!m::Send ^m  ; remember
^+!k::Send ^k  ; hyperlink to element
