﻿#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  Send, {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  Send, ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  Send, ^s
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

Space::
  Send, !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  Send, !{F4}
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command")
^`;::
	Gui, VimCommander:Add, Text,, &Command:
	; list names are the same as subroutine name, just replacing the space with _, and no final parentheses
	list = SM Plan||Window spy|Regex101|Watch later (YT)
	if Vim.State.IsCurrentVimMode("Vim_Normal") {
		list .= 
		mode_commander = n
	} else if Vim.State.StrIsInCurrentVimMode("Visual") {
		list .= Convert to lowercase (= u)|Convert to uppercase (= U)|Invert case (= ~)
		mode_commander = v
	}
	Gui, VimCommander:Add, Combobox, vCommand gAutoComplete, %list%
	Gui, VimCommander:Add, Button, default, &Execute
	Gui, VimCommander:Show,, Vim Commander
	Vim.State.SetMode("Insert")
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
	Gui, Destroy
return

VimCommanderButtonExecute:
	Gui, Submit
	Gui, Destroy
	if (command == "Watch later (YT)")
		command = watch_later_yt
	else if InStr("|" . list . "|", "|" . command . "|") {
		StringLower, command, command
		command := RegExReplace(command, " \(.*") ; removing parentheses
		command := StrReplace(command, " ", "_")
	} else { ; command has to be in the list. If not, google the command
		run https://www.google.com/search?q=%command% ; this could be a shorthand for searching
		Return
	}
	Gosub % command
Return

sm_plan:
	if WinExist("ahk_class TPlanDlg") {
		WinActivate
		Return
	}
	if WinExist("ahk_group SuperMemo") {
		WinActivate, ahk_class TElWind
		WinWaitActive, ahk_class TElWind,, 0
	} else {
		run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SuperMemo\SuperMemo.lnk
		WinWaitActive, ahk_class TElWind,, 5
		if ErrorLevel
			Return
	}
	send {alt}kp ; open Plan window
Return

window_spy:
	run C:\Program Files\AutoHotkey\WindowSpy.ahk
Return

regex101:
	run https://regex101.com/
Return

watch_later_yt:
	run https://www.youtube.com/playlist?list=WL
Return