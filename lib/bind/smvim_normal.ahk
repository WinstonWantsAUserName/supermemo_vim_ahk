﻿; Editing text only
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingText())
+h::  ; move to top of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickTop()
Return

+m::  ; move to middle of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickMid()
Return

+l::  ; move to bottom of screen
  ReleaseKey("shift")  ; to avoid clicking becomes selecting
  Vim.SM.ClickButtom()
Return

; Editing HTML
#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML())
^c::send {home}>{space}

#If (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsEditingHTML() && Vim.State.g)
+x::
x::  ; open hyperlink in current caret position (Open in *n*ew window)
  ReleaseKey("shift")
  Shift := InStr(A_ThisHotkey, "+")
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send +{right}^c{left}
  ClipWait, LongCopy ? 0.6 : 0.2, True
  If (clipboard ~= "\s" || !Clipboard) {
    send +{left}^c{right}
    ClipWait, LongCopy ? 0.6 : 0.2, True
  }
  If (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", CurrentLink)
    if (!CurrentLink) {
      Clipboard := ""
      send +{left}^c{right}
      ClipWait, LongCopy ? 0.6 : 0.2, True
      If (Vim.HTML.ClipboardGet_HTML(data)) {
        RegExMatch(data, "(<A((.|\r\n)*)href="")\K[^""]+", CurrentLink)
        if (!CurrentLink) {
          Vim.ToolTip("No link found.")
        } else if (InStr(CurrentLink, "SuperMemoElementNo=(")) {  ; goes to a supermemo element
          click(A_CaretX, A_CaretY, "right")
          send n
        } else {
          if (Shift) {
            Run % "iexplore.exe " . CurrentLink
          } else {
            run % CurrentLink
          }
        }
      }
    } else if (InStr(CurrentLink, "SuperMemoElementNo=(")) {  ; goes to a supermemo element
      click(A_CaretX, A_CaretY, "right")
      send n
    } else {
      if (Shift) {
        Run % "iexplore.exe " . CurrentLink
      } else {
        run % CurrentLink
      }
    }
  }
  Vim.State.SetMode()
  clipboard := ClipSaved
return

s::
  if (Vim.SM.IsLearning()) {
    ContinueLearning := true
  } else {
    ContinueLearning := false
  }
  WinGet, hwnd, ID, A
  send ^{f7}
  Vim.SM.SaveHTML()
  send {esc}  ; leave html
  WinClip.Snap(ClipData)
  Clipboard := ""
  send !{f12}fc  ; copy file path
  ClipWait 1
  if (!Clipboard) {
    Clipboard := ClipSaved
    return
  }
  Run % "C:\Program Files (x86)\Vim\vim82\gVim.exe " . Clipboard
  Vim.State.SetMode()
  Clipboard := ClipSaved
  WinWaitNotActive % "ahk_id " . hwnd
  WinWaitActive % "ahk_id " . hwnd
  send !{home}
  if (ContinueLearning) {
    ControlSend, TBitBtn2, {enter}, ahk_class TElWind
  } else {
    sleep 100
    send !{left}
  }
Return