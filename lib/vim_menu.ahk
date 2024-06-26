﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimMenu {
  __New(Vim) {
    this.Vim := Vim
  }

  SetMenu() {
    MenuVimSetting := ObjBindMethod(this.Vim.Setting, "ShowGui")
    MenuVimCheck := ObjBindMethod(this.Vim.Check, "CheckMenu")
    MenuVimStatus := ObjBindMethod(this.Vim.State, "FullStatus")
    MenuVimAbout := ObjBindMethod(this.Vim.About, "ShowGui")
    Menu, VimSubMenu, Add, Settings, % MenuVimSetting
    Menu, VimSubMenu, Add
    Menu, VimSubMenu, Add, Vim Check, % MenuVimCheck
    Menu, VimSubMenu, Add, Status, % MenuVimStatus
    Menu, VimSubMenu, Add, About vim_ahk, % MenuVimAbout

    Menu, Tray, Add
    Menu, Tray, Add, VimMenu, :VimSubMenu
  }
}
