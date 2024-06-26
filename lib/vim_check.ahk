﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimCheck {
  __New(Vim) {
    this.Vim := Vim
  }

  CheckMenu() {
    ; Additional message is necessary before checking current window.
    ; Otherwise process name cannot be retrieved...?
    Msgbox, , Vim Ahk, Checking current window...
    WinGet, process, PID, A
    WinGet, name, ProcessName, ahk_pid %process%
    WinGetClass, class, ahk_pid %process%
    WinGetTitle, title, ahk_pid %process%
    if (this.Vim.IsVimGroup()) {
      Msgbox, 0x40, Vim Ahk,
      (
        Supported
        Process name: %name%
        Class       : %class%
        Title       : %title%
      )
    } else {
      Msgbox, 0x10, Vim Ahk,
      (
        Not supported
        Process name: %name%
        Class       : %class%
        Title       : %title%
      )
    }
  }
}
