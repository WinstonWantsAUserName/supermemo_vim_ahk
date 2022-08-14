﻿#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Vim_Normal"))
:::Vim.State.SetMode("Command") ;(:)
; `;::Vim.State.SetMode("Command") ;(;)
#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command"))
w::Vim.State.SetMode("Command_w")
q::Vim.State.SetMode("Command_q")
h::
  send {F1}
  Vim.State.SetMode("Vim_Normal")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_w"))
Return::
  send ^s
  Vim.State.SetMode("Vim_Normal")
Return

q::
  send ^s^w
  Vim.State.SetMode("Insert")
Return

Space::  ; save as
  send !fa
  Vim.State.SetMode("Insert")
Return

#If Vim.IsVimGroup() and (Vim.State.IsCurrentVimMode("Command_q"))
Return::
  send ^w
  Vim.State.SetMode("Insert")
Return

; Commander, can be launched anywhere as long as vim_ahk is enabled
#If Vim.State.Vim.Enabled && !Vim.State.IsCurrentVimMode("Command")
^`;::
  ReleaseKey("ctrl")
  WinGet, hwnd, ID, A
  Gui, VimCommander:Add, Text,, &Command:
  ; list names are the same as subroutine name, just no space and no final parentheses
  list := "SM Plan||Window Spy|Regex101|Watch later (YT)|Search|Move mouse to caret|LaTeX|Wayback Machine|DeepL|YouGlish|Kill IE|Define (Google)|YT History In IE|Wiktionary|Discord go live|Lexico|Copy current window's title|Copy as HTML|Forvo|Pin current window at top|Acc Viewer|Translate (Google)(Web)|Clear clipboard|Forcellini|RAE|Show selection as html|Oxford Advanced Learner's Dictionary"
  if (WinActive("ahk_class TElWind") || WinActive("ahk_class TContents")) {
    list .= "|Set current element as concept hook|Memorise children of current element"
    if (Vim.SM.IsEditingText())
      list .= "|Cloze and Done!"
  } else if (WinActive("ahk_class TBrowser")) {
    list .= "|Memorise current browser"
  }
  Gui, VimCommander:Add, Combobox, vCommand gAutoComplete w196, % list
  Gui, VimCommander:Add, Button, default, &Execute
  Gui, VimCommander:Show,, Vim Commander
Return

VimCommanderGuiEscape:
VimCommanderGuiClose:
  Gui, Destroy
return

VimCommanderButtonExecute:
  Gui, Submit
  Gui, Destroy
  if (InStr("|" . list . "|", "|" . command . "|")) {
    command := RegExReplace(command, " |\(|\)|!|'")
  } else {  ; command has to be in the list. If not, google the command
    run % "https://www.google.com/search?q=" . command  ; this could be a shorthand for searching
    Return
  }
  Vim.State.SetMode("Insert",,,,, true)
  WinActivate % "ahk_id " . hwnd
  Gosub % command
Return

#If (Vim.State.Vim.Enabled)
^+!p::
  ReleaseKey("ctrl")
  ReleaseKey("shift")
  KeyWait alt
#if
SMPlan:
  if (!WinExist("ahk_group SuperMemo")) {
    run C:\ProgramData\Microsoft\Windows\Start Menu\Programs\SuperMemo\SuperMemo.lnk
    WinWaitActive, ahk_class TElWind,, 5
    if (ErrorLevel)
      Return
  }
  if (WinExist("ahk_class TPlanDlg"))
    WinClose
	CurrentTick := A_TickCount
  while (!WinExist("ahk_class TPlanDlg")) {
    if (WinExist("ahk_class TElParamDlg"))  ; ^+!p could trigger this
      WinClose
    if (WinExist("ahk_class TMsgDialog"))
      WinClose
    ControlSend, TBitBtn2, {ctrl down}p{ctrl up}, ahk_class TElWind
		if (A_TickCount := CurrentTick + 5000)
			return
  }
  WinActivate, ahk_class TPlanDlg
  Vim.State.SetMode("Vim_Normal")
Return

WindowSpy:
  run C:\Program Files\AutoHotkey\WindowSpy.ahk
Return

Regex101:
  run https://regex101.com/
Return

WatchLaterYT:
  run https://www.youtube.com/playlist?list=WL
Return

Search:
  SearchTerm := clip()
  if (!SearchTerm) {
    InputBox, SearchTerm, Google Search, Enter your search term.,, 192, 128
    if (!SearchTerm || ErrorLevel)
      return
  }
  SearchTerm := RegExReplace(SearchTerm, "(^\s*|\s*$)")
  if (RegExMatch(SearchTerm, "^https?:\/\/")) {
    run % SearchTerm
  } else {
    run % "https://www.google.com/search?q=" . SearchTerm
  }
Return

MoveMouseToCaret:
  MouseMove, % A_CaretX, % A_CaretY
  if (A_CaretX) {
    Vim.ToolTip("Current caret position: " . A_CaretX . " " . A_CaretY)
  } else {
    Vim.ToolTip("Caret not found.")
  }
Return

LaTeX:
  run https://latex.vimsky.com/
Return

WaybackMachine:
  url := clip()
  if (!url) {
    InputBox, url, Wayback Machine, Enter your URL.,, 192, 128
    if (!url || ErrorLevel)
      return
  }
  run % "https://web.archive.org/web/*/" . url
Return

DeepL:
  text := clip()
  if (!text) {
    InputBox, text, DeepL Translate, Enter your text.,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run % "https://www.deepl.com/en/translator#?/en/" . text
Return

YouGlish:
  term := clip()
  Gui, YouGlish:Add, Text,, &Term:
  Gui, YouGlish:Add, Edit, vTerm, % term
  Gui, YouGlish:Add, Text,, &Language:
  list := "English||Spanish|French|Italian|Japanese|German|Russian|Greek|Hebrew|Arabic|Polish|Portuguese|Korean|Turkish|American Sign Language"
  Gui, YouGlish:Add, Combobox, vLanguage gAutoComplete, % list
  Gui, YouGlish:Add, Button, default, &Search
  Gui, YouGlish:Show,, YouGlish
Return

YouGlishGuiEscape:
YouGlishGuiClose:
  Gui, Destroy
return

YouGlishButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (language == "American Sign Language")
    language := "signlanguage"
  run https://youglish.com/pronounce/%term%/%language%?
Return

KillIE:
  while WinExist("ahk_exe iexplore.exe")
    Process, Close, iexplore.exe
return

DefineGoogle:
  term := clip()
  Gui, GoogleDefine:Add, Text,, &Term:
  Gui, GoogleDefine:Add, Edit, vTerm, % term
  Gui, GoogleDefine:Add, Text,, &Language Code:
  list := "es||en|fr|it|ja|de|ru|el|he|ar|pl|pt|ko|sv|nl|tr"
  Gui, GoogleDefine:Add, Combobox, vLangCode gAutoComplete, % list
  Gui, GoogleDefine:Add, Button, default, &Search
  Gui, GoogleDefine:Show,, Google Define
Return

GoogleDefineGuiEscape:
GoogleDefineGuiClose:
  Gui, Destroy
return

GoogleDefineButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (LangCode) {
    run https://www.google.com/search?hl=%LangCode%&q=define+%term%&forcedict=%term%&dictcorpus=%LangCode%&expnd=1
  } else {
    run % "https://www.google.com/search?q=define+" . term
  }
return

ClozeAndDone:
  if (!clip())
    return
  send !z
  Vim.SM.WaitProcessing()
  if (WinActive("ahk_class TMsgDialog"))  ; warning on trying to cloze on items
    Return
  send ^+{enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; "Do you want to remove all element contents from the collection?"
  send {enter}
  WinWaitNotActive, ahk_class TElWind,, 0  ; wait for "Delete element?"
  send {enter}
  Vim.State.SetNormal()
Return

YTHistoryInIE:
  run iexplore.exe https://www.youtube.com/feed/history
Return

Wiktionary:
  term := clip()
  Gui, Wiktionary:Add, Text,, &Term:
  Gui, Wiktionary:Add, Edit, vTerm, % term
  Gui, Wiktionary:Add, Text,, &Language:
  list := "Spanish||English|French|Italian|Japanese|German|Russian|Greek|Hebrew|Arabic|Polish|Portuguese|Korean|Turkish|Latin|Ancient Greek|Chinese"
  Gui, Wiktionary:Add, Combobox, vLanguage gAutoComplete, % list
  Gui, Wiktionary:Add, Button, default, &Search
  Gui, Wiktionary:Show,, Wiktionary
Return

WiktionaryGuiEscape:
WiktionaryGuiClose:
  Gui, Destroy
return

WiktionaryButtonSearch:
  Gui, Submit
  Gui, Destroy
  if (language == "Ancient Greek")
    language := "Ancient_Greek"
  run % "https://en.wiktionary.org/wiki/" . term . "#" . language
return

#if (WinActive("ahk_exe Discord.exe"))
^!l::
#if
DiscordGoLive:
  if (FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share.png", "r") || FindClick(A_ScriptDir . "\lib\bind\util\discord_screen_share_alt.png", "r")) {
    sleep 800
    send {tab 2}{enter}
    sleep 400
    send {tab}{enter}
    sleep 400
    send +{tab 2}{enter}
  }
return

Lexico:
  term := clip()
  if (!term) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run https://www.lexico.com/definition/%term%?s=t
return

CopyCurrentWindowsTitle:
  Clipboard := WinGetTitle("A")
  Vim.ToolTip("Copied " . Clipboard)
return

CopyAsHTML:
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (!Clipboard) {
    Clipboard := ClipSaved
    Return
  }
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    Clipboard := data
  }
  Vim.ToolTip("Copied`n`n" . data)
Return

Forvo:
  term := clip()
  if (!term) {
    InputBox, term, Lexico, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run http://forvo.com/search/%term%/
Return

PinCurrentWindowAtTop:
  Winset, Alwaysontop, , A
return

SetCurrentElementAsConceptHook:
  if (WinActive("ahk_class TElWind")) {
    send !c
    WinWaitActive, ahk_class TContents,, 0
  }
  if (ControlGetFocus() == "TVTEdit1")
    send {enter}
  ControlFocusWait("TVirtualStringTree1")
  send {AppsKey}ce
  WinWaitActive, ahk_class TMsgDialog,, 1  ; either asking for confirmation or "no change"
  if (!ErrorLevel)
    send {enter}
  ControlSend, TVirtualStringTree1, {esc}, ahk_class TContents
  Vim.ToolTip("Hook set.")
  Vim.State.SetMode("Vim_Normal")
Return

AccViewer:
  run % A_ScriptDir . "\lib\util\AccViewer Source.ahk"
return

TranslateGoogleWeb:
  text := clip()
  if (!text) {
    InputBox, text, Google Translate, Enter your text.,, 192, 128
    if (!text || ErrorLevel)
      return
  }
  run https://translate.google.com/?sl=auto&tl=en&text=%text%&op=translate
return

ClearClipboard:
  run % ComSpec . " /c echo off | clip"
return

MemoriseChildrenOfCurrentElement:
  send ^{space}
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  Gosub MemoriseCurrentBrowser
return

MemoriseCurrentBrowser:
  send {AppsKey}cn  ; find pending elements
  WinWaitActive, ahk_class TProgressBox,, 0
  if (!ErrorLevel)
    WinWaitNotActive, ahk_class TProgressBox,, 10
  WinWaitActive, ahk_class TBrowser,, 0
  send {AppsKey}ple  ; remember
return

Forcellini:
  term := clip()
  if (!term) {
    InputBox, term, Forcellini, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "http://lexica.linguax.com/forc2.php?searchedLG=" . term
return

RAE:
  term := clip()
  if (!term) {
    InputBox, term, RAE, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "https://dle.rae.es/" . term . "?m=form"
return

ShowSelectionAsHTML:
  WinClip.Snap(ClipData)
  LongCopy := A_TickCount, Clipboard := "", LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent clipwait will need
  send ^c
  ClipWait, LongCopy ? 0.6 : 0.2, True
  if (Vim.HTML.ClipboardGet_HTML(data)) {
    RegExMatch(data, "s)(?<=<!--StartFragment-->).*(?=<!--EndFragment-->)", data)
    Clipboard := data
    MsgBox, 4, , % "Open in Vim?`n`n" . data
    IfMsgBox yes
    {
      Run C:\Program Files (x86)\Vim\vim82\gVim.exe
      WinWaitActive, ahk_class Vim,, 0
      send "{+}p{enter}  ; paste from clipboard
    }
  }
  WinClip.Restore(ClipData)
return

OxfordAdvancedLearnersDictionary:
  term := clip()
  if (!term) {
    InputBox, term, Oxford Advanced Learner's Dictionary, Enter your search term.,, 192, 128
    if (!term || ErrorLevel)
      return
  }
  run % "https://www.oxfordlearnersdictionaries.com/definition/english/" . term . "?q=" . term
return