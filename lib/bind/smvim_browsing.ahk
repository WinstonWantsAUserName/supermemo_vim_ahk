﻿; Hotkeys in this file are inspired by Vimium: https://github.com/philc/vimium

; g state on top to have higher priority
; putting those below would make gu stops working (u also triggers scroll up)

; Element window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && Vim.State.g)
g::Vim.Move.Move("g")  ; 3gg goes to the 3rd line of entire text

+s::  ; gS: open link in IE
SMGoToLink:
s::  ; gs: go to link
  Vim.State.SetMode()
  link := Vim.SM.GetLink()
  if (link) {
    if (InStr(A_ThisHotkey, "+")) {
      ; run % "iexplore.exe " . Link  ; RIP IE
      Vim.Browser.RunInIE(link)
    } else {
      run % Link
    }
  } else {
    ToolTip("No link found.")
  }
Return

; Element/content window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) && !Vim.SM.IsEditingText() && Vim.State.g)
+e::  ; K, gE: go up one *e*lement
  send !{pgup}
  Vim.State.SetMode()
Return

e::  ; J, ge: go down one *e*lement
  send !{pgdn}
  Vim.State.SetMode()
Return

0::  ; g0: go to root element
  send !{home}
  Vim.State.SetMode()
Return

$::  ; g$: go to last element
  send !{end}
  Vim.State.SetMode()
Return

; Element window / browser
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && (WinActive("ahk_class TElWind") || WinActive("ahk_class TBrowser")) && !Vim.SM.IsEditingText() && Vim.State.g)
; g state, for both browsing and editing
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && Vim.State.g)
c::  ; gc: go to next *c*omponent
  send ^t
  Vim.State.SetMode()
Return

+c::  ; gC: go to previous *c*omponent
  Vim.SM.PostMsg(992, true)
  Vim.State.SetMode()
Return

; Need scrolling bar present
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
; Scrolling
h::Vim.Move.Repeat("h")
l::Vim.Move.Repeat("l")
^e::
j::Vim.Move.Repeat("j")
^y::
k::Vim.Move.Repeat("k")
d::Vim.Move.Repeat("^d")
u::Vim.Move.Repeat("^u")
Return

; "Browsing" mode
; Unlike Vim, 3gg and 3G work differently
; 3gg goes to the 3rd line in the entire document
; 3G goes to the 3rd line on screen
+g::Vim.Move.Move("+g")

; OG Vim commands
i::Vim.State.SetMode("Insert")
:::Vim.State.SetMode("Command") ;(:)

; Browser-like actions
r::  ; reload
  ContinueGrading := Vim.SM.IsGrading()
  ContinueLearning := ContinueGrading ? 0 : Vim.SM.IsLearning()
  send !{home}
  if (ContinueLearning) {
    Vim.SM.Learn()
  } else if (ContinueGrading) {
    Vim.SM.Learn()
    ControlTextWait("TBitBtn3", "Show answer")
    ControlSend, TBitBtn3, {enter}
  } else {
    Vim.SM.WaitFileLoad()
    if (WinActive("ahk_class Internet Explorer_TridentDlgFrame"))  ; sometimes could happen on YT videos
      send {esc}
    send !{left}
  }
return

n::send !n  ; create new topic
+n::send !a  ; create new item
x::send {del}  ; delete element/component
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || WinActive("ahk_class TContents")
   || WinActive("ahk_class TBrowser")))
+x::send ^+{enter}  ; Done!

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
p::
  send ^{f10}  ; replay auto-play
  WinWaitActive, ahk_class TMsgDialog,, 0
  if (!ErrorLevel)
    send y 
return

+p::send ^{t 2}{f9}  ; play video in default system player / edit script component
^i::send ^{f8}  ; download images

; Element navigation
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
+h::send !{left}  ; go back in history
+l::send !{right}  ; go forward in history
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
+j::send !{pgdn}  ; J, ge: go down one element
+k::send !{pgup}  ; K, gE: go up one element

; Open windows
c::send !c  ; open content window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())
c::send !c  ; refocus
#if (Vim.IsVimGroup()
  && Vim.State.IsCurrentVimMode("Vim_Normal")
  && ((WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
   || (WinActive("ahk_class TContents") && Vim.SM.IsNavigatingContentWindow())))
b::
  if (WinExist("ahk_class TBrowser")) {
    WinActivate
  } else {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    SetDefaultKeyboard(0x0409)  ; english-US	
    send ^{space}  ; open browser
  }
return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TBrowser"))
b::WinActivate, ahk_class TBrowser  ; why not

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText() && !Vim.State.g)
o::
  Vim.State.SetMode("Insert")
  send ^o  ; favourites
  BackToNormal := 1
return

f::Vim.SM.ClickMid()  ; click on html component

; Copy
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
y::Vim.State.SetMode("Vim_ydc_y", 0, -1, 0)
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_ydc_y") && WinActive("ahk_class TElWind") && !Vim.SM.IsEditingText())
y::  ; yy: copy current source url
  link := Vim.SM.GetLink()
  if (!link) {
    ToolTip("Link not found.")
  } else {
    ToolTip("Copied " . link)
    Clipboard := link
  }
  Vim.State.SetNormal()
return

e::  ; ye: duplicate current element
  send !d
  Vim.State.SetNormal()
Return

; Plan/tasklist window
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingPlan())
s::ControlClickWinCoord(253, 48)  ; *s*witch plan
b::send !b  ; begin
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && Vim.SM.IsNavigatingTask())
s::ControlClickWinCoord(153, 52)  ; *s*witch tasklist

; Browsing/editing
#if Vim.IsVimGroup() and Vim.State.IsCurrentVimMode("Vim_Normal") && WinActive("ahk_class TElWind") and (Vim.State.g)
{::Vim.Move.Move("{")
}::Vim.Move.Move("}")

#if Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind")
'::
  send ^{f3}
  Vim.State.SetMode("Insert")
  BackToNormal := 2
Return

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
^f7::
m::
  if (Vim.SM.IsEditingHTML())
    Vim.SM.ClickMid()
  send ^{f7}  ; set read point
  ToolTip("Read point set")
Return

!f7::
`::
  send !{f7}  ; go to read point
  ToolTip("Go to read point")
Return

!m::
^+f7::
  send ^+{f7}  ; clear read point
  ToolTip("Read point cleared")
Return

!+j::send !+{pgdn}  ; go to next sibling
!+k::send !+{pgup}  ; go to previous sibling

#if (Vim.IsVimGroup() && (Vim.State.IsCurrentVimMode("Vim_Normal") || Vim.State.StrIsInCurrentVimMode("Visual")) && !Vim.State.fts && WinActive("ahk_class TElWind"))
^/::  ; visual
^+/::  ; visual and start from the beginning
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind"))
>+/:  ; caret on the right
<+/:  ; start from top
!/::  ; followed by a cloze
^!/::  ; followed by a cloze and stays in clozed item
+!/::  ; followed by a cloze hinter
^+!/::  ; also cloze hinter but stays in clozed item
/::  ; better search
  CtrlState := InStr(A_ThisHotkey, "^")  ; visual
  ShiftState := InStr(A_ThisHotkey, "+")  ; caret on the right
  RShiftState := InStr(A_ThisHotkey, ">+")  ; caret on the right
  LShiftState := InStr(A_ThisHotkey, "<+")  ; start from top
  AltState := InStr(A_ThisHotkey, "!")  ; followed by a cloze
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && !Vim.State.fts && WinActive("ahk_class TElWind") && (GetKeyState("alt") || GetKeyState("ctrl")))
CapsLock & /::
  CapsState := InStr(A_ThisHotkey, "CapsLock")
  if (A_ThisHotkey == "CapsLock & /") {
    AltState := GetKeyState("alt")
    CtrlState := GetKeyState("ctrl")
  }
  if (!Vim.SM.IsEditingText()) {
    send ^t
    Vim.SM.WaitTextFocus()  ; make sure CurrFocus is updated    
    if (!Vim.SM.IsEditingText()) {  ; still found no text
      ToolTip("Text not found.")
      Vim.State.SetNormal()
      return
    }
  } 
  if (Vim.State.StrIsInCurrentVimMode("Visual")) {
    send {right}
    Vim.State.SetNormal()
  }
  if (LShiftState)
    send ^{Home}
  ControlGetFocus, CurrFocus, ahk_class TElWind
  if (AltState) {
    gui, Search:Add, Text,, &Find text:`n(your search result will be clozed)
  } else if (CtrlState) {
    gui, Search:Add, Text,, &Find text:`n(will go to visual mode after the search)
  } else {
    gui, Search:Add, Text,, &Find text:
  }
  gui, Search:Add, Edit, vUserInput w196, % VimLastSearch
  gui, Search:Add, CheckBox, vWholeWord, Match &whole word only
  gui, Search:Add, Button, default, &Search
  sleep 50  ; short sleep so element won't try to regain focus
  gui, Search:Show,, Search
return

SearchGuiEscape:
SearchGuiClose:
  gui destroy
return

SearchButtonSearch:
  gui submit
  gui destroy
  if (!UserInput)
    Return
  VimLastSearch := UserInput  ; register UserInput into VimLastSearch
  ; Previously, UserInput is stored in Vim.Move.LastSearch, but it turned out this would add 000... in floating numbers
  ; i.e. 3.8 would become 3.80000
  WinActivate, ahk_class TElWind
  if (InStr(CurrFocus, "TMemo")) {
    send ^a
    if (Vim.State.n) {
      n := Vim.State.n
      Vim.State.n := 0
    } else {
      n := 1
    }
    pos := InStr(clip(), UserInput, true,, n)
    if (pos) {
      pos -= 1
      send {left}{right %pos%}
      input_len := StrLen(UserInput)
      if (RShiftState) {
        send {right %input_len%}
      } else if (CtrlState || AltState) {
        send +{right %input_len%}
        if (CtrlState) {
          Vim.State.SetMode("Vim_VisualFirst")
        } else if (AltState) {
          send !z
        }
      }
    } else {
      ToolTip("Not found.")
      Vim.State.SetNormal()
      Return
    }
  } else {
    send {esc}  ; esc to exit field, so it can return to the same field later
    Vim.SM.WaitTextExit(2000)
    send {f3}
    WinWaitActive, ahk_class TMyFindDlg,, 0
    if (ErrorLevel) {
      send {esc}^{enter}  ; open commander
      send {text}h  ; Highlight: Clear
      send {enter}{f3}
      WinWaitActive, ahk_class TMyFindDlg,, 0
      if (ErrorLevel)
        return
    }
    UserInput := trim(UserInput)  ; spaces need to be trimmed otherwise SM might eat the spaces in text
    ControlSetText, TEdit1, % UserInput
    if (WholeWord)
      send !w  ; match whole word
    send !c  ; match case
    send {enter}
    if (Vim.State.n) {
      send % "{f3 " . Vim.State.n - 1 . "}"
      Vim.State.n := 0
    }
    WinWaitNotActive, ahk_class TMyFindDlg,, 0  ; faster than wait for element window to be active
    if (ErrorLevel)
      return
    if (!AltState) {
      if (RShiftState) {
        send {right}  ; put caret on right of searched text
      } else if (CtrlState) {
        Vim.State.SetMode("Vim_VisualFirst")
      } else {  ; all modifier keys are not pressed
        send {left}  ; put caret on left of searched text
      }
    }
    send ^{enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
    WinWaitActive, ahk_class TCommanderDlg,, 1
    if (ErrorLevel) {
      ToolTip("Not found.")
      Vim.State.SetNormal()
      send {esc}^{enter}
      send {text}h  ; Highlight: Clear
      send {enter}{esc}
      return
    }
    send {text}h
    send {enter}
    if WinExist("ahk_class TMyFindDlg")  ; clears search box window
      WinClose
    if (AltState) {
      if (!CtrlState && !ShiftState && !CapsState) {
        send !z
      } else if (ShiftState) {
        if (CtrlState)
          ClozeHinterCtrlState := 1
        WinWaitActive, ahk_class TElWind,, 0
        gosub ClozeHinter
      } else if (CapsState) {
        if (CtrlState)
          ClozeNoBracketCtrlState := 1
        WinWaitActive, ahk_class TElWind,, 0
        gosub ClozeNoBracket
      } else if (CtrlState) {
        gosub ClozeStay
      }
    } else if (!CtrlState) {  ; alt is up and ctrl is up; shift can be up or down
      send {esc}^t  ; to return to the same field
    } else if (CtrlState) {  ; sometimes SM doesn't focus to anything after the search
      WinWaitActive, ahk_class TElWind,, 0
      if (!ControlGetFocus())
        ControlFocus, % CurrFocus, ahk_class TElWind
    }
  }
return