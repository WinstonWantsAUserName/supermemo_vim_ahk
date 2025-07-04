#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class SM {
  __New() {
    this.CssClass := "cloze|extract|clozed|hint|note|ignore|headers|reftext"
                   . "|reference|highlight|tablelabel|anti-merge|uppercase"
                   . "|italic|bold|underline|italic-bold|italic-underline"
                   . "|bold-underline|small-caps|smallcaps"
                   . "|ilya-frank-translation|overline|italic-overline"
                   . "|bold-overline|underline-overline|sub-left"
                   . "|sub-lefter"
  }

  DoesTextExist(RestoreClip:=true) {
    if (WinExist("ahk_class TElWind")) {
      if (ControlGet(,, "Internet Explorer_Server1") || ControlGet(,, "TMemo1") || ControlGet(,, "TRichEdit1")) {
        return true
      } else {
        return IfContains(this.GetTemplCode(RestoreClip), "Type=Text", true)
      }
    }
  }

  DoesHTMLExist() {
    return ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind")
  }

  WaitHTMLExist(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.DoesHTMLExist()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  Click(pos, Control:="") {
    if (!IfIn(pos,"h,m,l"))
      return false
    if (Control || this.IsEditingText()) {
      Control := Control ? Control : ControlGetFocus()
    } else if (WinExist("ahk_class TElWind")) {
      if (ControlGet(,, "Internet Explorer_Server2")) {  ; item
        Control := "Internet Explorer_Server2"
      } else if (ControlGet(,, "Internet Explorer_Server1")) {  ; topic
        Control := "Internet Explorer_Server1"
      } else {  ; no html field found
        if (!this.DoesTextExist())
          return false
        this.EditFirstQuestion(), this.WaitTextFocus()
        Control := ControlGetFocus("ahk_class TElWind")
      }
    }

    WinExist("ahk_class TElWind")  ; update last found window
    if (IfIn(pos,"m,l"))
      ControlGetPos,,,, Height, % Control
    if (pos = "h") {
      ControlClick, % Control,,,,, NA x1 y1
    } else if (pos = "m") {
      ControlClick, % Control,,,,, % "NA x1 y" . Height / 2
    } else if (pos = "l") {
      ControlClick, % Control,,,,, % "NA x1 y" . Height - 2
    }
    return true
  }

  IsEditingHTML() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "Internet Explorer_Server"))
  }

  IsEditingPlainText() {
    return (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "TMemo,TRichEdit"))
  }

  IsEditingText() {
    if (this.IsEditingHTML()) {
      return "HTML"
    } else if (this.IsEditingPlainText()) {
      return "Text"
    }
  }

  IsBrowsing() {
    return (WinActive("ahk_class TElWind") && !this.IsEditingText())
  }

  IsBrowsingBG() {
    return (WinExist("ahk_class TElWind") && !IfContains(ControlGetFocus(), "Internet Explorer_Server,TMemo,TRichEdit"))
  }

  IsGrading() {
    ; If SM is focusing on either 5 of the grading buttons or the cancel button
    if (WinActive("ahk_class TElWind"))
      return (ControlGetFocus() ~= "^TBitBtn[4-9]$")
  }

  IsNavigating() {
    return (this.IsNavigatingPlan() || this.IsNavigatingTask() || this.IsNavigatingContentWind() || this.IsNavigatingBrowser() || WinActive("ahk_class TImgDown") || WinActive("ahk_class TChoicesDlg") || WinActive("ahk_class TChecksDlg"))
  }

  IsNavigatingPlan() {
    return (WinActive("ahk_class TPlanDlg") && (ControlGetFocus() == "TStringGrid1"))
  }

  IsNavigatingTask() {
    return (WinActive("ahk_class TTaskManager") && (ControlGetFocus() == "TStringGrid1"))
  }

  IsNavigatingContentWind() {
    return (WinActive("ahk_class TContents") && (ControlGetFocus() == "TVirtualStringTree1"))
  }

  IsNavigatingBrowser() {
    return (WinActive("ahk_class TBrowser") && (ControlGetFocus() == "TStringGrid1"))
  }

  SetPrio(Prio) {
    this.PostMsg(655, true)
    WinWait, % "ahk_class TPriorityDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
    ControlSetText, TEdit5, % Prio
    while (WinExist())
      ControlSend, TEdit5, {Enter}
  }

  SetRandPrio(min, max) {
    Prio := Random(min, max)
    global SMImportGuiHwnd, Vim
    if (WinActive("A") == SMImportGuiHwnd) {
      ControlFocus, Edit1
      ControlSetText, Edit1, % Prio
      Send {tab}^a
    } else if (this.IsPrioInputBox()) {
      ControlSetText, Edit1, % Prio
      ControlFocus, Edit1
      Send ^a
    } else if (WinActive("ahk_class TPriorityDlg")) {  ; priority dialogue
      ControlSetText, TEdit5, % Prio
      ControlFocus, TEdit1  ; interval
    } else if (WinExist("ahk_class TElWind")) {
      this.SetPrio(Prio)
    }
    Vim.State.SetNormal()
  }

  SetInterval(Interval) {
    if (WinActive("ahk_class TElWind")) {
      Send ^j
      Send % "{Text}" . Interval
      Send {Enter 2}
      ; WinWait, % "ahk_class TGetIntervalDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
      ; ControlSend, TEdit2, % "{text}" . Interval
      ; while (WinExist())
      ;   ControlSend, TEdit2, {Enter}
      global Vim
      Vim.State.SetNormal()
    } else if (WinActive("ahk_class TPriorityDlg")) {
      ; ControlSetText, TEdit1, % Interval
      this.SetText("TEdit1", Interval)
      ControlFocus, TEdit5  ; priority
    }
  }

  SetRandInterval(min, max) {
    this.SetInterval(Random(min, max))
  }

  SetRandTaskVal(min, max) {
    ControlSetText, TEdit8, % random(min, max), A
    ControlFocus, TEdit7, A
    global Vim
    Vim.State.SetMode("Insert")
  }

  MoveToLast(RestoreClip:=true) {
    Send ^{End}^+{Up}  ; if there are references this would select (or deselect in visual mode) them all
    if (InStr(Copy(RestoreClip), "#SuperMemo Reference:")) {
      Send {Up}{Left}
    } else {
      Send ^{End}
    }
  }

  ExitText(ReturnToComp:=false, Timeout:=0) {
    this.ActivateElWind(), ret := 1
    if (this.IsEditingText()) {
      hCtrl := ControlGet(,,, "ahk_class TElWind")
      if (this.HasTwoComp() || this.IsEditingPlainText()) {  ; plain text items may not be able to be detected as having 2 components
        Send ^t
        hCtrl := ControlWaitHwndChange(, hCtrl, "ahk_class TElWind")
        if (ReturnToComp) {
          this.PrevComp()
          hCtrl := ControlWaitHwndChange(, hCtrl, "ahk_class TElWind")
        }
        ret := 2
      }
      Send {Esc}
      if (!ControlWaitHwndChange(, hCtrl, "ahk_class TElWind",,,, Timeout))
        return 0
    }
    return ret
  }

  WaitTextExit(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (WinActive("ahk_class TElWind") && this.IsBrowsing()) {
        return true
      } else if (this.IsNavWnd() || (Timeout && (A_TickCount - StartTime > Timeout))) {  ; choices because reference could update
        return false
      }
    }
  }

  WaitTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingText()) {
        return this.IsEditingText()
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitHTMLFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingHTML()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitPlainTextFocus(Timeout:=0) {
    StartTime := A_TickCount
    loop {
      if (this.IsEditingPlainText()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  WaitClozeProcessing(Timeout:=0) {
    this.PrepStatBar(1), StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(false, "Please wait", -1)) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        return 0
      }
    }
    if (WinActive("ahk_class TMsgDialog")) {  ; warning on trying to cloze on items
      this.PrepStatBar(2)
      return -1
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(false, "Please wait", Timeout)
        Sleep 200
        this.PrepStatBar(2)
        return 1
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        Return 0
      }
    }
  }

  WaitExtractProcessing(Timeout:=0) {
    this.PrepStatBar(1), StartTime := A_TickCount
    loop {
      if (!A_CaretX) {
        Break
      } else if (A_CaretX && this.WaitFileLoad(false, "Loading file", Timeout)) {  ; prevent looping forever
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        return false
      }
    }
    loop {
      if (A_CaretX) {
        this.WaitFileLoad(false, "Loading file", Timeout)
        Sleep 200
        this.PrepStatBar(2)
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        this.PrepStatBar(2)
        Return false
      }
    }
  }

  VimEnterInsertIfSpelling(Timeout:=700) {
    StartTime := A_TickCount
    loop {
      Sleep 100
      if (WinActive("ahk_class TElWind") && IfContains(ControlGetFocus(), "TMemo")) {
        global Vim
        Vim.State.SetMode("Insert")
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        Return
      }
    }
  }

  IsLearning(wSMElWind:="ahk_class TElWind") {
    CurrText := ControlGetText("TBitBtn3", wSMElWind)
    if (CurrText == "Next repetition") {
      return 2
    } else if (CurrText == "Show answer") {
      return 1
    }
  }

  PlayIfOnlineColl(CollName:="", Timeout:=1500) {
    CollName := CollName ? CollName : this.GetCollName()
    if (CollName ~= "i)^(bgm|piano)$")
      return
    if (this.IsOnline(CollName, -1)) {
      StartTime := A_TickCount
      if (ControlTextWait("TBitBtn3", "Next repetition", "ahk_class TElWind",,,, Timeout)) {
        WinActivate, ahk_class TElWind
        this.AutoPlay()
        return true
      } else {
        return false
      }
    }
  }

  SaveHTML(MaxLoop:=15) {
    loop {
      this.RegMember(true)
      WinWaitActive, ahk_class TRegistryForm,, 0.1
      if (!ErrorLevel) {
        WinClose
        WinWaitActive, ahk_class TElWind
        return true
      }
      if (A_Index > MaxLoop)
        return false
    }
  }

  RefreshHTML(Timeout:="") {
    if (!this.OpenNotepad(Timeout))
      return false
    ControlSend,, {Ctrl Down}w{Ctrl Up}
    WinClose
    WinActivate, ahk_class TElWind
    WinWaitActive, ahk_class TElWind,, % Timeout
    return true
  }

  GetCollName(Text:="") {
    Text := Text ? Text : WinGetText("ahk_class TElWind")
    RegExMatch(Text, "m)^.+?(?= \(SuperMemo)", CollName)
    return CollName
  }

  GetCollPath(Text:="") {
    Text := Text ? Text : WinGetText("ahk_class TElWind")
    RegExMatch(Text, "m)\(SuperMemo .*?: \K.+(?=\)$)", CollPath)
    return CollPath
  }

  GetLink(TemplCode:="", RestoreClip:=true) {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(RestoreClip)
    RegExMatch(TemplCode, "(?<=#Link: <a href="").*?(?="">)", Link)
    return html_decode(Link)
  }

  GetCommentInTemplCode(TemplCode:="", RestoreClip:=true) {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(RestoreClip)
    RegExMatch(TemplCode, "(?<=#Comment: ).*?(?=<\/FONT><\/SuperMemoReference>)", Comment)
    return Comment
  }

  GetLinksInComment(TemplCode:="", RestoreClip:=true) {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(RestoreClip)
    return GetAllLinks(this.GetCommentInTemplCode(TemplCode, RestoreClip))
  }

  GetFilePath(RestoreClip:=true) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(993, true)
    } else {
      this.PostMsg(987, true)
    }
    ClipWait, % LongCopy ? 0.6 : 0.2, True
    TemplCode := Clipboard
    if (RestoreClip)  ; for scripts that restore clipboard at the end
      Clipboard := ClipSaved
    return TemplCode
  }

  LoopForFilePath(RestoreClip:=true, MaxLoop:=8) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    loop {
      if (FilePath := this.GetFilePath(false))
        Break
      if (A_Index > MaxLoop)
        return
    }
    if (RestoreClip)
      Clipboard := ClipSaved
    return FilePath
  }

  SetTitle(Title:="", Timeout:="") {
    if (WinGetTitle("ahk_class TElWind") == Title)
      return true
    Timeout := Timeout ? Timeout / 1000 : Timeout
    BlockInput, On
    this.AltT()
    GroupAdd, SMAltT, ahk_class TChoicesDlg
    GroupAdd, SMAltT, ahk_class TTitleEdit
    WinWait, % "ahk_group SMAltT ahk_pid " . pidSM := WinGet("PID", "ahk_class TElWind"),, % Timeout
    if (WinGetClass() == "TChoicesDlg") {
      if (Title == "")
        ControlFocus, TGroupButton2
      while (WinExist("ahk_class TChoicesDlg ahk_pid " . pidSM))
        ControlClick, TBitBtn2,,,,, NA
      if (Title != "")
        WinWait, % "ahk_class TTitleEdit ahk_pid " . pidSM, % Timeout
    }
    if (WinGetClass() == "TTitleEdit") {
      if (Title != "")
        ControlSetText, TMemo1, % Title
      ControlSend, TMemo1, {Enter}
    }
    BlockInput, Off
  }

  GetDefaultConcept() {
    return ControlGetText("TEdit1", "ahk_class TElWind")
  }

  IsOnline(CollName:="", CurrConcept:="") {
    CollName := CollName ? CollName : this.GetCollName()
    ; Online collections
    if (IfIn(CollName, "passive,singing,piano,calligraphy,drawing,bgm,music"))
      return 2
    CurrConcept := CurrConcept ? CurrConcept : this.GetDefaultConcept()
    ; Online concepts
    if (IfIn(CurrConcept, "Online,Sources"))
      return 1
  }

  PostMsg(msg, ContextMenu:=false, wSMElWind:="ahk_class TElWind") {
    if (ContextMenu) {
      DHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
    }

    if (wSMElWind == "ahk_class TElWind") {
      wPost := "ahk_class TElWind"
      WinGet, pahSMElWind, List, ahk_class TElWind
      loop % pahSMElWind {
        pidSM := WinGet("PID", "ahk_id " . hWnd := pahSMElWind%A_Index%)
        if (WinExist("ahk_class TProgressBox ahk_pid " . pidSM)) {
          Continue
        } else {
          WndFound := true, wPost := "ahk_id " . hWnd
          Break
        }
      }
    } else {
      pidSM := WinGet("PID", wSMElWind)
      wPost := "ahk_class TElWind ahk_pid " . pidSM, WndFound := true
    }

    if (!WndFound) {
      MB := MsgBox(3,, "SuperMemo is processing something. Do you want to launch a new window?"
                     . "`n(Press no to wait; also please switch to main SM window if not automatically switched)")
      if (MB = "Yes") {
        Run, % "C:\SuperMemo\sm19.exe"
        WinWaitActive, ahk_class TElWind
      } else if (MB = "No") {
        GroupAdd, SMProcessing, ahk_class TProgressBox
        GroupAdd, SMProcessing, ahk_class TElWind
        WinActivate, ahk_group SMProcessing
        WinWaitActive, ahk_group SMProcessing
        if (WinGetClass() == "TProgressBox")
          WinWaitClose
        WinWaitActive, ahk_class TElWind
      } else {
        if (ContextMenu)
          DetectHiddenWindows, % DHW
        WinExist(wSMElWind)  ; update last found window
        return
      }
    }

    if (ContextMenu) {  ; https://zhuanlan.zhihu.com/p/412553730
      WinGet, paContextMenuID, List, ahk_class TPUtilWindow
      loop % paContextMenuID {
        hWnd := paContextMenuID%A_Index%
        wPost := "ahk_id " . hWnd
        if (WinGet("PID", wPost) == pidSM)
          PostMessage, 0x0111, % msg,,, % wPost
      }
    } else {
      PostMessage, 0x0111, % msg,,, % wPost
    }
    if (ContextMenu)
      DetectHiddenWindows, % DHW
    WinExist(wSMElWind)  ; update last found window
    return true
  }

  GetTemplCode(RestoreClip:=true, wSMElWind:="ahk_class TElWind", WaitTime:=-1) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    this.PostMsg(693, true, wSMElWind)  ; Alt + F10 -> Template -> Copy template
    if (WaitTime == -1) {
      ClipWait, % LongCopy ? 0.6 : 0.2, True
    } else if (WaitTime == 0) {
      ClipWait,, True
    } else if (WaitTime) {
      ClipWait, % WaitTime, True
    }
    TemplCode := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return TemplCode
  }

  PrepStatBar(step) {
    static
    if (step == 1) {
      if (!WinGetText("ahk_class TStatBar"))
        this.PostMsg(313), RestoreStatBar := true
      if (WinActive("ahk_group SM")) {
        RestoreMouse := true, CMM := A_CoordModeMouse
        CoordMode, Mouse, Screen
        MouseGetPos, xSaved, ySaved
        MouseMove, 0, 0, 0
      }
    } else if (step == 2) {
      if (RestoreMouse) {
        RestoreMouse := false
        MouseMove, xSaved, ySaved, 0
        CoordMode, Mouse, % CMM
      }
      if (RestoreStatBar)
        this.PostMsg(313), RestoreStatBar := false
    }
  }

  WaitFileLoad(PrepStatBar:=true, Add:="", Timeout:=0) {  ; used for reloading or waiting for an element to load
    LFW := WinExist()  ; save last found window
    if (PrepStatBar)
      this.PrepStatBar(1)
    while (WinExist("ahk_class Internet Explorer_TridentDlgFrame ahk_pid " . WinGet("PID", "ahk_class TElWind")))  ; sometimes could happen in YT videos
      WinClose
    if (Add != "")
      Add := "|" . Add
    Match := "Priority=|Downloading|\(\d+ item\(s\)" . Add
    if (Timeout == -1) {
      ret := (WinGetText("ahk_class TStatBar") ~= Match)
    } else {
      StartTime := A_TickCount
      loop {
        if (WinGetText("ahk_class TStatBar") ~= Match) {
          ret := true
          Break
        } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
          ret := false
          Break
        }
      }
    }
    if (PrepStatBar)
      this.PrepStatBar(2)

    WinExist("ahk_id " . LFW)
    return ret
  }

  WaitStatBarRegEx(Text, PrepStatBar:=true, Timeout:=0) {
    if (PrepStatBar)
      this.PrepStatBar(1)
    while (WinExist("ahk_class Internet Explorer_TridentDlgFrame ahk_pid " . WinGet("PID", "ahk_class TElWind")))  ; sometimes could happen in YT videos
      WinClose
    StartTime := A_TickCount
    loop {
      t := RegExReplace(WinGetText("ahk_class TStatBar"), "^(\s+)?")
      if (t ~= Text) {
        ret := true
        Break
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        ret := false
        Break
      }
    }
    if (PrepStatBar)
      this.PrepStatBar(2)
    return ret
  }

  Learn(CtrlL:=true, AutoPlay:=false, EnterInsert:=false, wSMElWind:="ahk_class TElWind") {
    this.ActivateElWind(wSMElWind)
    Btn2Text := ControlGetText("TBitBtn2")
    Btn3Text := ControlGetText("TBitBtn3")
    if (CtrlL) {
      if (WinGet("ProcessName") == "sm19.exe") {
        this.PostMsg(178)
      } else {
        this.PostMsg(180)
      }
    } else if (Btn2Text == "Learn") {
      ControlClick, TBitBtn2,,,,, NA
    } else if (Btn3Text == "Learn") {
      ControlClick, TBitBtn3,,,,, NA
    } else if (Btn3Text == "Next repetition") {
      ControlClick, TBitBtn3,,,,, NA
    }
    if (AutoPlay)
      this.PlayIfOnlineColl()
    if (EnterInsert)
      this.VimEnterInsertIfSpelling()
  }

  Reload(Timeout:=0) {
    this.GoHome()
    this.WaitFileLoad(,, Timeout)
    this.GoBack()
  }

  IsCssClass(Text) {
    return (IfContains("|" . this.CssClass . "|", "|" . Text . "|"))
  }

  SetText(Control, Text:="", w:="", CheckName:=true) {
    ControlSetText, % Control, % SubStr(Text, 2), % w
    ControlSend, % Control, % "{text}" . SubStr(Text, 1, 1), % w
    if (CheckName)
      ControlTextWait(Control, Text, w)
  }

  SetDefaultConcept(Concept:="", Prio:="", CheckConceptExist:="") {
    if (Concept && !Prio && !CheckConceptExist) {
      if (this.GetDefaultConcept() == Concept)
        return true
    }

    ; Click default concept button via UIA
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    ; Just using ControlClick() cannot operate in background
    pos := el.FindFirstBy("ControlType=Button AND Name='DefaultConceptBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")

    if (Concept || (Prio >= 0)) {
      WinWait, % wReg := "ahk_class TRegistryForm ahk_pid " . WinGet("PID", "ahk_class TElWind")

      if (CheckConceptExist) {
        this.SetText("Edit1", CheckConceptExist, wReg)
        ret := this.RegCheck(CheckConceptExist,, wReg)
        if (ret == "")
          return false
        UpdateCheckConcept := ret
      }

      if (Concept) {  ; set concept
        this.SetText("Edit1", Concept, wReg)
        if (this.RegCheck(Concept,, wReg) == "")
          return false
      }

      if (Prio >= 0) {  ; set priority
        PrevPrio := ControlGetText("TEdit1", wReg)
        if (Prio != PrevPrio) {
          w := "ahk_id " . WinActive("A")
          WinActivate, % wReg  ; cannot send in background
          ControlFocus, TEdit1, % wReg
          ControlFocusWait("TEdit1", wReg)
          Send % "{text}" . Prio
          WinActivate, % w
        }
      }

      if (Concept) {
        ControlSend, Edit1, {Enter}, % wReg
      } else if (Prio >= 0) {
        WinClose, % wReg
      }

      WinExist(wReg)  ; update last found window
      WinWaitClose
      if (UpdateCheckConcept)
        return UpdateCheckConcept
      return (PrevPrio >= 0) ? PrevPrio : true
    }
  }

  ClickElWindSourceBtn() {
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(WinExist("ahk_class TElWind"))
    ; Just using ControlClick() cannot operate in background
    pos := el.FindFirstBy("ControlType=Button AND Name='ReferenceBtn'").GetCurrentPos("screen")
    ControlClickScreen(pos.x, pos.y, "ahk_class TElWind")
  }

  ClickBrowserSourceButton() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ControlClickWinCoordDPIAdjusted(320, 45, "ahk_class TBrowser") 
    } else {
      ControlClickWinCoordDPIAdjusted(294, 45, "ahk_class TBrowser") 
    }
  }

  SetElParam(Title:="", Prio:="", Template:="", Group:="", CheckGroup:=false) {
    Critical
    if ((Title == "") && !(Prio >= 0) && !Template && !Group) {
      return true
    } else if ((Title != "") && !(Prio >= 0) && !Template && !Group) {
      this.SetTitle(Title)
      return true
    } else if ((Title == "") && (Prio >= 0) && !Template && !Group) {
      this.SetPrio(Prio)
      return true
    }

    ; Launch element parameter window
    w := "ahk_class TElParamDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
    this.PostMsg(708, true)
    WinWait, % w

    if (Template && !(ControlGetText("Edit1") = Template)) {
      this.SetText("Edit1", Template)
      this.WaitFileLoad()
    }
    if ((Title != "") && (ControlGetText("TEdit2") != Title))
      this.SetText("TEdit2", Title)
    if ((Prio >= 0) && (ControlGetText("TEdit1") != Prio))
      this.SetText("TEdit1", Prio)
    if (Group && !(ControlGetText("Edit2") = Group))
      this.SetText("Edit2", Group,, CheckGroup)

    ; Submit
    ControlFocus, TMemo1  ; needed, otherwise the window won't close sometimes
    while (WinExist(w))
      ControlSend, TMemo1, {Enter}
    return true
  }

  IsNavWnd() {  ; navigation window
    if (WinActive("ahk_class TChoicesDlg")) {
      return ((ControlGetText("TGroupButton1") == "Cancel (i.e. restore the old version of references)")
           && (ControlGetText("TGroupButton2") == "Combine old and new references for this element")
           && (ControlGetText("TGroupButton3") == "Change references in all elements produced from the original article")
           && (ControlGetText("TGroupButton4") == "Change only the references of the currently displayed element"))
          || ((ControlGetText("TGroupButton5") == "Go to the root element of the concept")
           && (ControlGetText("TGroupButton4") == "Transfer the current element to the concept")
           && (ControlGetText("TGroupButton3") == "View the last child of the root")
           && (ControlGetText("TGroupButton2") == "Review the elements in the concept")
           && (ControlGetText("TGroupButton1") == "Cancel"))
    }
  }

  CheckDup(Text, ClearHighlight:=true, wSMElWind:="ahk_class TElWind", ToolTip:="No duplicates found.") {  ; try to find duplicates
    pidSM := WinGet("PID", wSMElWind)
    while (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM) || WinExist("ahk_class TBrowser ahk_pid " . pidSM))
      WinClose
    ContLearn := this.IsLearning(wSMElWind)
    Text := LTrim(Text)  ; LTrim() is necessary bc SuperMemo LITERALLY MODIFIES the html
    Text := RegExReplace(Text, "^file:\/\/\/", "file://")  ; SuperMemo converts file:/// to file://
    Text := RegExReplace(Text, "^https?:\/\/", "://")  ; SuperMemo import is inconsistent about https and http
    Text := RegExReplace(Text, "^:\/\/www\.youtube\.com", "youtube.com")  ; SuperMemo eats the www in www.youtube.com
    if (IsUrl(Text))
      Text := this.HTMLUrl2SMRefUrl(Text)
    ret := this.CtrlF(Text, ClearHighlight, ToolTip, wSMElWind)
    if ((ContLearn == 1) && this.LastCtrlFNotFound)
      this.Learn(wSMElWind)
    return ret
  }

  HTMLUrl2SMRefUrl(Url) {
    ; Can't just encode URI, Chinese characters will also be encoded
    ; For some reason, SuperMemo only encodes some part of the url
    ; Probably because of SuperMemo uses a lower version of IE?
    Url := StrReplace(Url, "%20", " ")
    Url := StrReplace(Url, "%21", "!")
    Url := StrReplace(Url, "%22", """")
    Url := StrReplace(Url, "%23", "#")
    Url := StrReplace(Url, "%24", "$")
    Url := StrReplace(Url, "%25", "%")
    Url := StrReplace(Url, "%26", "&")
    Url := StrReplace(Url, "%27", "'")
    Url := StrReplace(Url, "%28", "(")
    Url := StrReplace(Url, "%29", ")")
    Url := StrReplace(Url, "%2A", "*")
    Url := StrReplace(Url, "%2B", "+")
    Url := StrReplace(Url, "%2C", ",")
    Url := StrReplace(Url, "%2D", "-")
    Url := StrReplace(Url, "%2E", ".")
    Url := StrReplace(Url, "%2F", "/")
    Url := StrReplace(Url, "%3A", ":")
    Url := StrReplace(Url, "%3B", ";")
    Url := StrReplace(Url, "%3C", "<")
    Url := StrReplace(Url, "%3D", "=")
    Url := StrReplace(Url, "%3E", ">")
    Url := StrReplace(Url, "%3F", "?")
    Url := StrReplace(Url, "%40", "@")
    Url := StrReplace(Url, "%5B", "[")
    Url := StrReplace(Url, "%5C", "\")
    Url := StrReplace(Url, "%5D", "]")
    Url := StrReplace(Url, "%5E", "^")
    Url := StrReplace(Url, "%5F", "_")
    Url := StrReplace(Url, "%60", "`")
    Url := StrReplace(Url, "%7B", "{")
    Url := StrReplace(Url, "%7C", "|")
    Url := StrReplace(Url, "%7D", "}")
    Url := StrReplace(Url, "%7E", "~")
    if (IfContains(Url, "youtube.com/watch?v="))  ; sm19 deletes www from www.youtube.com
      Url := StrReplace(Url, "www.")
    return Url
  }

  CtrlF(Text, ClearHighlight:=true, ToolTip:="Not found.", wSMElWind:="ahk_class TElWind") {
    this.LastCtrlFNotFound := false
    if (!WinExist("ahk_class TElWind"))
      return
    this.CloseMsgDialog(wSMElWind)
    if (WinGet("ProcessName", wSMElWind) == "sm19.exe") {
      ret := this.PostMsg(143,, wSMElWind)
    } else {
      ret := this.PostMsg(144,, wSMElWind)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TMyFindDlg ahk_pid " . pidSM := WinGet("PID", wSMElWind)
    ControlSetText, TEdit1, % Text
    ControlFocus, TEdit1
    ControlSend, TEdit1, {Enter}
    GroupAdd, SMCtrlF, ahk_class TMsgDialog
    GroupAdd, SMCtrlF, ahk_class TBrowser
    WinWait, % "ahk_group SMCtrlF ahk_pid " . pidSM
    if (ret := (WinGetClass() == "TBrowser")) {  ; window from the last WinWait
      if (ClearHighlight)
        this.ClearHighlight(wSMElWind)
      WinActivate, % "ahk_class TBrowser ahk_pid " . pidSM
    } else if (WinGetClass() == "TMsgDialog") {
      this.LastCtrlFNotFound := true
      WinClose
      SetToolTip(ToolTip)
      if (ClearHighlight)
        this.ClearHighlight(wSMElWind)
    }
    return ret
  }

  ClearHighlight(wSMElWind:="ahk_class TElWind") {
    return this.Command("h", wSMElWind)
  }

  Command(Text, wSMElWind:="ahk_class TElWind") {
    if (WinGet("ProcessName", wSMElWind) == "sm19.exe") {
      ret := this.PostMsg(238,, wSMElWind)
    } else {
      ret := this.PostMsg(240,, wSMElWind)
    }
    if (!ret)
      return false
    WinWait, % "ahk_class TCommanderDlg ahk_pid " . pidSM := WinGet("PID", wSMElWind)
    ControlSetText, TEdit2, % Text
    ControlTextWait("TEdit2", Text)
    while (WinExist("ahk_class TCommanderDlg ahk_pid " . pidSM)) {
      ControlClick, TButton4,,,,, NA
      if (WinExist("ahk_class #32770 ahk_pid " . pidSM))
        ControlSend,, {Esc}
    }
    return true
  }

  MakeReference(html:=false) {
    Break := html ? "<br>" : "`n"
    Text := Break . "#SuperMemo Reference:"
    global Browser
    if (Browser.Url)
      Text .= Break . "#Link: " . this.HTMLUrl2SMRefUrl(Browser.Url)
    if (Browser.Title)
      Text .= Break . "#Title: " . Browser.Title
    if (Browser.Source)
      Text .= Break . "#Source: " . Browser.Source
    if (Browser.Author)
      Text .= Break . "#Author: " . Browser.Author
    if (Browser.Date)
      Text .= Break . "#Date: " . Browser.Date
    if (Browser.Comment)
      Text .= Break . "#Comment: " . Browser.Comment
    return Text
  }

  HandleF3(step) {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      msg := 145
    } else {
      msg := 146
    }
    if (step == 1) {
      this.PostMsg(msg)  ; f3
      WinWaitActive, ahk_class TMyFindDlg,, 0.7
      if (ErrorLevel) {  ; SM goes to the next found without opening find dialogue
        this.ClearHighlight()  ; clears highlight so it opens find dialogue
        this.PostMsg(msg)
        WinWaitActive, ahk_class TMyFindDlg,, 3
        if (ErrorLevel) {
          SetToolTip("F3 window cannot be launched.")
          return false
        }
      }
      return true
    } else if (step == 2) {
      Send ^{Enter}  ; open commander; convienently, if a "not found" window pops up, this would close it
      WinWait, % "ahk_class TMyFindDlg ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.3  ; sometimes the f3 dialogue will still pop up
      GroupAdd, SMF3, ahk_class TMyFindDlg
      GroupAdd, SMF3, ahk_class TCommanderDlg
      WinWaitActive, ahk_group SMF3
      if (WinGetClass() == "TMyFindDlg") {  ; ^enter closed "not found" window
        WinClose
        this.ClearHighlight()
        Send {Esc}
        global Vim
        Vim.State.SetNormal()
        SetToolTip("Text not found.")
        return false
      } else if (WinGetClass() == "TCommanderDlg") {  ; ^enter opened commander
        Send {text}h  ; clear highlight
        Send {Enter}
        WinWaitNotActive
        this.PostMsg(msg)
        WinWaitActive, ahk_class TMyFindDlg
        WinClose
        SwitchToSameWindow("ahk_class TElWind")
        return true
      }
    }
  }

  GoToTopIfLearning(LearningState:=0) {
    if ((!LearningState && this.IsLearning())
      || (LearningState && (this.IsLearning() == LearningState)))
      this.GoHome()
  }

  GoHome(ForceBG:=false) {
    this.PostMsg(772, true)
  }

  GoBack(ForceBG:=false) {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(780, true)
    } else {
      this.PostMsg(778, true)
    }
  }

  AutoPlay(Acrobat:=false) {
    this.CloseMsgDialog()
    this.ActivateElWind(), SetToolTip("Running...")
    auiaText := this.GetUIAArray()
    Marker := this.GetMarkerFromUIAArray(auiaText)
    SMTitle := WinGetTitle("ahk_class TElWind")

    if (Acrobat) {
      this.EditFirstQuestion()
      Send ^t{f9}
      if (Path := this.GetFilePath())
        Run, % "acrobat.exe " . Path
    } else {

      RefLink := this.GetLinkFromUIAArray(auiaText)
      if (IfContains(RefLink, "youtube.com")) {
        ; If it's a YT video, it's best to have the browser open first,
        ; so the extentions (eg, adblockers) can be launched
        RegExMatch(DefaultBrowser := DefaultBrowser(), ".*\\\K.*$", v)
        if (!WinExist(wBrowser := "ahk_exe " . v)) {
          Run, % DefaultBrowser
          WinWaitActive, % wBrowser
        }
      }

      if (Marker == "SMVim: Use online video progress") {
        global Browser
        Browser.SearchInYT(SMTitle, RefLink)
      } else {
        ControlSend,, {Ctrl Down}{F10}{Ctrl Up}, ahk_class TElWind
        WinWait, % "ahk_class TMsgDialog ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0
        if (!ErrorLevel) {
          WinActivate
          Send {text}y
        }
      }
    }

    ToolTip := "Running: `n`nTitle: " . SMTitle
    if (Comment := this.GetCommentFromUIAArray(auiaText))
      ToolTip .= "`nComment: " . Comment
    if (Marker ~= "^SMVim(?!:)") {
      ToolTip .= "`n" . StrUpper(SubStr(Marker, 7, 1)) . SubStr(Marker, 8)
      str := SubStr(Marker, 7)
      RegExMatch(str, "^.*?(?=:)", MarkerName)
      RegExMatch(str, "(?<=: ).*$", MarkerContent)
    }
    if (!Marker) {
      TemplCode := this.GetTemplCode()
      if (!IfContains(TemplCode, "Type=Script,Type=Binary", true)) {
        SetToolTip("Script or binary component not found.")
        return False
      }
    }
    WinWaitNotActive, ahk_class TElWind
    while (!hReader := WinActive("A"))
      Continue
    wReader := "ahk_id " . hReader

    if (MarkerName = "read point") {
      if (WinActive("ahk_group Browser")) {
        uiaBrowser := new UIA_Browser(wReader)
        uiaBrowser.WaitPageLoad(,, 0)
      }
      t := "Do you want to search read point?"
         . "`n`nTitle: " . SMTitle
         . "`nRead point: " . MarkerContent
      if (MsgBox(3,, t) = "Yes") {
        if (WinGetClass(wReader) == "SUMATRA_PDF_FRAME") {
          ControlFocus, Edit2, % wReader
          ControlSetText, Edit2, % MarkerContent, % wReader
          ControlSend, Edit2, {Enter}, % wReader
        } else {
          Send ^f
          Sleep 200
          if (Calibre := WinActive("ahk_exe ebook-viewer.exe"))
            Sleep 200
          Clip(MarkerContent)
          Send {Enter}
          if (Calibre)
            Send {Enter}
        }
      }

    } else if (MarkerName = "page mark") {
      if ((WinGetClass(wReader) == "SUMATRA_PDF_FRAME") || (WinGet("ProcessName", wReader) == "WinDjView.exe")) {
        if (ControlGetText("Edit1", wReader) != MarkerContent) {  ; target page mark is not current page mark
          if (MsgBox(3,, "Do you want to go to page mark?") = "Yes") {
            ControlFocus, Edit1, % wReader
            ControlSetText, Edit1, % MarkerContent, % wReader
            ControlSend, Edit1, {Enter}, % wReader
          }
        }
      } else if (Acrobat) {
        btn := GetAcrobatPageBtn()
        if (btn.Value != MarkerContent) {  ; target page mark is not current page mark
          if (MsgBox(3,, "Do you want to go to page mark?") = "Yes") {
            btn.ControlClick()
            Sleep 100
            Send ^a
            Send % "{text}" . MarkerContent
            Send {Enter}
          }
        }
      }
    } else {
      SetToolTip(ToolTip, 10000)
    }
  }

  AltT() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(115)
    } else {
      ret := this.PostMsg(116)
    }
    return ret
  }

  RunLink(Url, RunInIE:=false) {
    if (RegExMatch(Url, "SuperMemoElementNo=\((\d+)\)", v)) {  ; goes to a SuperMemo element
      this.GoToEl(v1)
    } else {
      if (RunInIE) {
        global Browser
        Browser.RunInIE(Url)
      } else {
        if ((Url ~= "file:\/\/") && (Url ~= "#.*"))
          TempUrl := Url, Url := RegExReplace(Url, "#.*")
        try Run, % Url
        catch
          return false
        if (TempUrl) {
          WinWaitActive, ahk_group Browser
          uiaBrowser := new UIA_Browser("A")
          uiaBrowser.SetUrl(TempUrl, true)
        }
      }
    }
    return true
  }

  EditFirstQuestion() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(117)
    } else {
      this.PostMsg(118)
    }
  }

  EditFirstAnswer() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(118)
    } else {
      this.PostMsg(119)
    }
  }

  EditAll() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(119)
    } else {
      this.PostMsg(120)
    }
  }

  EditRef(wSMElWind:="ahk_class TElWind") {
    ; this.ActivateElWind(wSMElWind)
    ; Send !{f10}fe
    this.PostMsg(660, true, wSMElWind)
  }

  AltA() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(93)
    } else {
      this.PostMsg(95)
    }
  }

  CtrlN() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(94)
    } else {
      this.PostMsg(96)
    }
  }

  AltN() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(96)
    } else {
      this.PostMsg(98)
    }
  }

  WaitBrowser(Timeout:=1) {
    WinWaitActive, ahk_class TProgressBox,, % Timeout
    if (!ErrorLevel)
      WinWaitClose
    WinWaitActive, ahk_class TBrowser
    this.WaitFileLoad()
  }

  WaitFileBrowser() {
    GroupAdd, SMCtrlQ, ahk_class TFileBrowser
    GroupAdd, SMCtrlQ, ahk_class TMsgDialog
    WinWaitActive, ahk_group SMCtrlQ
    while (!WinActive("ahk_class TFileBrowser")) {
      while (WinActive("ahk_class TMsgDialog"))
        WinClose  ; Directory not found; Create?
      WinWaitActive, ahk_group SMCtrlQ
    }
  }

  ; Pressing Q makes you focus on first text; this makes it as fast as possible
  SpamQ(SpamInterval:=100, Timeout:=0) {
    loop {
      this.EditFirstQuestion()
      if (SpamInterval && this.WaitTextFocus(SpamInterval)) {
        return true
      } else if (!SpamInterval && this.IsEditingText()) {
        return true
      } else if (Timeout && (A_TickCount - StartTime > Timeout)) {
        return false
      }
    }
  }

  HasTwoComp() {
    return ((ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind") && ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind"))
      || (ControlGet(,, "TMemo2", "ahk_class TElWind") && ControlGet(,, "TMemo1", "ahk_class TElWind")))
  }

  ActivateElWind(wSMElWind:="ahk_class TElWind") {
    if (!WinActive(wSMElWind))
      WinActivate, % wSMElWind
    WinExist(wSMElWind)  ; update last found window
  }

  AskPrio(SetPrio:=true) {
    Prio := InputBox(, "Enter priority:")
    if (ErrorLevel) {  ; user pressed cancel
      return -1
    } else if (Prio == "") {  ; user pressed enter without entering a priority
      return
    } else if (Prio >= 0) {
      if (Prio ~= "^\.")
        Prio := "0" . Prio
      if (SetPrio)
        this.SetPrio(Prio)
      return Prio
    }
  }

  CloseMsgDialog(wSMElWind:="ahk_class TElWind") {
    pidSM := WinGet("PID", wSMElWind)
    while (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM))
      WinClose
  }

  OpenNotepad(PostMsg:=true, Timeout:="") {
    this.ActivateElWind()
    if (PostMsg) {
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        this.PostMsg(995, true)
      } else {
        this.PostMsg(989, true)
      }
    } else {
      Send !{F12}fw
    }
    GroupAdd, OpenNP, ahk_class TMsgDialog
    GroupAdd, OpenNP, ahk_exe Notepad.exe
    WinWaitActive, ahk_group OpenNP,, % Timeout
    if (ErrorLevel)
      return false
    if (WinGetClass() == "TMsgDialog") {
      WinClose
      WinWaitActive, ahk_class TElWind
      Send ^t
      this.OpenNotepad(PostMsg)
    }
    return true
  }

  Plan() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      ret := this.PostMsg(241)
    } else {
      ret := this.PostMsg(243)
    }
    return ret
  }

  IsItem(TemplCode:="") {
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode()
    return InStr(TemplCode, "`r`nType=Item`r`n", true)
  }

  FileBrowserSetPath(path, enter:=false) {
    if (!WinActive("ahk_class TFileBrowser"))
      return false
    RegexMatch(path, "^(.):", v), drive := v1
    t := ControlGetText("TDriveComboBox1")
    if !(t ~= "i)^" . v) {
      ControlSend, TDriveComboBox1, % drive
      ControlTextWaitChange("TDriveComboBox1", t)
    }
    ControlSetText, TEdit1, % path
    ControlTextWait("TEdit1", path)
    if (enter)
      ControlClick, TButton2,,,,, NA
  }

  EditBar(n) {
    UIA := UIA_Interface(), el := UIA.ElementFromHandle(WinActive("A"))
    el.FindFirstBy("ControlType=TabItem AND Name='Edit'").ControlClick()
    el.WaitElementExist("ControlType=ToolBar AND Name='Format'").FindByPath(n).ControlClick()
    el.FindFirstBy("ControlType=TabItem AND Name='Learn'").ControlClick()
    SwitchToSameWindow()
  }

  PasteHTML(PostMsg:=true) {
    if (PostMsg) {
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        this.PostMsg(922, true)
      } else {
        this.PostMsg(843, true)
      }
    } else {
      this.ActivateElWind()
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        Send {AppsKey}cs
      } else {
        Send {AppsKey}xp
      }
    }
    global WinClip
    WinClip._waitClipReady()
    WinWait, % "ahk_class TProgressBox ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.3
    if (!ErrorLevel)
      WinWaitClose
  }

  HandleSM19PoundSymbUrl(Url) {
    if ((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") && IfContains(Url, "#")) {
      this.PostMsg(154)  ; text registry
      ShortUrl := RegExReplace(Url, "#.*")
      pidSM := WinGet("PID", "ahk_class TElWind")
      WinWait, % "ahk_class TRegistryForm ahk_pid " . pidSM
      wReg := "ahk_id " . WinExist()
      this.SetText("Edit1", ShortUrl)
      this.RegAltR()
      WinWait, % "ahk_class TInputDlg ahk_pid " . pidSM
      if (ControlGetText("TMemo1") == ShortUrl)
        ControlSetText, TMemo1, % Url
      ControlSend, TMemo1, {Ctrl Down}{Enter}{Ctrl Up}  ; submit
      WinWaitClose
      WinWait, % "ahk_class TChoicesDlg ahk_pid " . pidSM,, 0.3
      if (!ErrorLevel) {
        ControlFocus, TGroupButton3
        ControlClick, TBitBtn2,,,,, NA
        WinWaitClose
        WinWait, % "ahk_class TChoicesDlg ahk_pid " . pidSM
        ControlFocus, TGroupButton2
        ControlClick, TBitBtn2,,,,, NA
        WinWaitClose
      }
      WinClose, % wReg
      return true
    }
  }

  GetElNumber(TemplCode:="", RestoreClip:=true) {
    if (WinExist("ahk_class TElDataWind ahk_pid " . WinGet("PID", "ahk_class TElWind"))) {
      RegExMatch(WinGetTitle(), "^(Item|Topic|Concept|Task) #([\d,]+):", v)
      return StrReplace(v2, ",")
    }
    TemplCode := TemplCode ? TemplCode : this.GetTemplCode(RestoreClip)
    RegExMatch(TemplCode, "Begin Element #(\d+)", v)
    return v1
  }

  PoundSymbLinkToComment() {
    global Browser
    if ((WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") && IfContains(Browser.Url, "#")) {
      PoundSymbCommentList := "workflowy.com"
      if (IfContains(Browser.Url, PoundSymbCommentList)) {
        Browser.Comment := Browser.Url
        return true
      }
    }
  }

  EmptyHTMLComp() {
    loop {
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        this.PostMsg(941, true)
      } else {
        this.PostMsg(935, true)
      }
      WinWait, % "ahk_class TMsgDialog ahk_pid " . WinGet("PID", "ahk_class TElWind"),, 0.7
      if (!ErrorLevel) {
        ControlSend, ahk_parent, {Enter}
        WinWaitClose
        Break
      }
    }
  }

  OpenBrowser() {
    ; Sometimes a bug makes that you can't use ^space to open browser in content window
    ; After a while, I found out it's due to my Chinese input method
    ; SetDefaultKeyboard(0x0409)  ; English-US
    ; Send ^{Space}  ; open browser
    if (WinActive("ahk_class TElWind")) {
      this.PostMsg(721, true)
    } else if (WinActive("ahk_class TContents")) {
      ControlSend, ahk_parent, {Ctrl Down}{Space}{Ctrl Up}
    }
  }

  GetUIAArray() {
    UIA := UIA_Interface()
    el := UIA.ElementFromHandle(ControlGet(,, "Internet Explorer_Server1", "ahk_class TElWind"))
    if (!Ref := el.FindFirstByName("#SuperMemo Reference:"))  ; item
      el := UIA.ElementFromHandle(ControlGet(,, "Internet Explorer_Server2", "ahk_class TElWind"))
    return el.FindAllByType("text")
  }

  GetLinkFromUIAArray(auiaText:="") {
    auiaText := auiaText ? auiaText : this.GetUIAArray()
    for i, v in auiaText {
      if (v.Name == "#Link: ")
        return v.FindByPath("+1").Name
    }
  }

  GetCommentFromUIAArray(auiaText:="") {
    auiaText := auiaText ? auiaText : this.GetUIAArray()
    Comment := ""
    for i, v in auiaText {
      if (RegExMatch(v.Name, "^#Comment: (.*)$", t)) {
        Comment .= t1, CommentReached := true
        Continue
      }
      if (CommentReached && !(v.Name ~= "^#(Parent|Article): "))
        Comment .= v.Name
      if (v.Name ~= "^#(Parent|Article): ")
        Break
    }
    return Comment
  }

  GetMarkerFromUIAArray(auiaText:="") {
    auiaText := auiaText ? auiaText : this.GetUIAArray()
    for i, v in auiaText {
      if ((i == 1) && (v.Name == "#SuperMemo Reference:")) {  ; empty html
        return
      } else if ((i == 1) && (v.Name ~= "^SMVim (read point|page mark|time stamp)")) {
        return v.Name . v.FindByPath("+1").Name
      } else if ((i == 1) && (v.Name == "SMVim: Use online video progress")) {
        return v.Name
      } else {
        return
      }
    }
  }

  IsHTMLEmpty(auiaText:="") {
    auiaText := auiaText ? auiaText : this.GetUIAArray()
    for i, v in auiaText {
      if ((i == 1) && (v.Name == "#SuperMemo Reference:")) {
        return true
      } else {
        return false
      }
    }
  }

  GetParentElNumber(auiaText:="") {
    auiaText := auiaText ? auiaText : this.GetUIAArray()
    for i, v in auiaText {
      if (v.Name == "#Article: ")
        return v.FindByPath("+1").Name
    }
  }

  IsCompMarker(Text) {
    if (RegExMatch(Text, "^SMVim (.*?):", v)) {
      return v1
    } else {
      return false
    }
  }

  ListLinks() {
    this.ActivateElWind()
    Send !{f10}cs
  }

  LinkConcept(Concept:="", wSMElWind:="ahk_class TElWind", wForeground:="") {
    this.CloseMsgDialog(), this.PostMsg(644, true, wSMElWind)
    return this.RegWindEnterConcept(Concept, wSMElWind, wForeground)
  }

  UnLinkConcept(Concept:="", wSMElWind:="ahk_class TElWind", wForeground:="") {
    this.CloseMsgDialog(), this.PostMsg(645, true, wSMElWind)
    return this.RegWindEnterConcept(Concept, wSMElWind, wForeground)
  }

  RegWindEnterConcept(Concept:="", wSMElWind:="ahk_class TElWind", wForeground:="") {
    if (wForeground)
      WinActivate, % wForeground  ; sometimes it robs the focused window
    if (Concept) {
      pidSM := WinGet("PID", wSMElWind)
      WinWait, % wReg := "ahk_class TRegistryForm ahk_pid " . pidSM
      this.SetText("Edit1", Concept, wReg)
      if (this.RegCheck(Concept, wSMElWind, wReg) == "")
        return
      ControlSend, Edit1, {Enter}, % wReg
      loop {
        if (WinExist("ahk_class TMsgDialog ahk_pid " . pidSM)) {
          WinClose
          Break
        } else if (!WinExist(wReg)) {
          Break
        }
      }
      WinWaitClose, % wReg  ; necessary, otherwise the action of wReg closing will activate TElWind
      return true
    }
  }

  RegCheck(Text, wSMElWind:="ahk_class TElWind", wReg:="ahk_class TRegistryForm") {
    this.RegAltR(wReg)
    WinWait, % "ahk_class TInputDlg ahk_pid " . WinGet("PID", wSMElWind)
    CurrText := ControlGetText("TMemo1")
    WinClose
    if (InStr(CurrText, Text) != 1) {
      WinActivate, % wReg
      MB := MsgBox(3,, "Current concept doesn't seem like your entered concept. Continue?")
      WinWaitActive, % wReg
      if (IfIn(MB, "No,Cancel")) {
        WinClose
        return
      }
      this.RegAltR(wReg)
      WinWait, % "ahk_class TInputDlg ahk_pid " . WinGet("PID", wSMElWind)
      ret := ControlGetText("TMemo1")
      WinClose
      WinExist(wReg)  ; update last found window
      return ret
    }
    WinExist(wReg)  ; update last found window
    return Text
  }

  Cloze() {
    this.ActivateElWind()
    Send !z
    ; Wait for prompt for changing reference
    WinWaitActive, ahk_class TChoicesDlg,, 0.7
    if (!ErrorLevel) {
      WinClose
      loop 3 {
        WinWaitActive, ahk_class TChoicesDlg,, 1.5
        if (!ErrorLevel)
          WinClose
      }
    }
  }

  ; Return 1 to continue, 0 to stop, -1 to start again
  AskToSearchLink(BrowserUrl, CurrSMUrl, BrowserTitle:="", wSMElWind:="ahk_class TElWind") {
    BrowserUrl := this.HTMLUrl2SMRefUrl(BrowserUrl)
    if (IfContains(BrowserUrl, "britannica.com")) {
      ret := IfContains(BrowserUrl, CurrSMUrl)
    } else {
      ret := (CurrSMUrl == BrowserUrl)
    }
    if (ret)
      return 1
    wCurr := "ahk_id " . WinActive("A")
    global Browser
    t := "Link in SM reference is not the same as in the browser. Continue?"
       . "`n(press no to execute a search)"
       . "`nBrowser url: " . BrowserUrl
       . "`n       SM url: " . CurrSMUrl
       . "`n`nBrowser title: " . (BrowserTitle ? BrowserTitle : Browser.GetFullTitle())
       . "`n       SM title: " . WinGetTitle(wSMElWind)
    MB := MsgBox(3,, t), ret := 0
    if ((MB = "No") && this.CheckDup(BrowserUrl,, wSMElWind, "Link not found in collection.")) {
      MB := MsgBox(3,, "Found. Continue?")
      WinClose, % "ahk_class TBrowser ahk_pid " . WinGet("PID", wSMElWind)
      if (MB = "Yes") {
        WinWaitActive, % wSMElWind
        ret := -1
        WinActivate, % wCurr
      }
    } else if (MB = "Yes") {
      ret := 1
    }
    return ret
  }

  CleanHTML(str, Nuke:=false, LineBreak:=false, Url:="") {
    ; zzz in case you used f6 in SuperMemo to remove format before,
    ; which disables the tag by adding zzz (eg, <FONT> -> <ZZZFONT>)

    ; All attributes removal detects for <> surrounding
    ; however, sometimes if a text attribute is used, and it has HTML tag
    ; style and others removal might not be working
    ; Example: https://www.scientificamerican.com/article/can-newborn-neurons-prevent-addiction/
    ; This will likely not be fixed

    RegExMatch(str, r := "i)^<strong><font color=""?blue""?>.*? : <\/font><\/strong>", SMSplit)
    if (SMSplit)
      str := RegExReplace(str, r, SMSplitPlaceHolder := GetDetailedTime())

    if (nuke) {
      ; Classes
      str := RegExReplace(str, "is)<[^>]+\K\sclass="".*?""(?=([^>]+)?>)")
      str := RegExReplace(str, "is)<[^>]+\K\sclass=[^ >]+(?=([^>]+)?>)")
    }

    if (LineBreak)
      str := RegExReplace(str, "i)<(BR|(\/)?DIV)", "<$2P")

    if (IfContains(Url, "economist.com")) {
      str := StrReplace(str, "<small", "<small class=uppercase")
      str := RegExReplace(str, "i)<(\/)?DIV", "<$1P")
      ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-family: var\(--ds-type-system-.*?-smallcaps\))(?=[^>]+>)", " class=uppercase ")
    }

    if (IfContains(Url, "baike.baidu.com")) {
      str := RegExReplace(str, "i)<(\/)?DIV", "<$1P")
    }

    if (IfContains(Url, "wikipedia.org,wikibooks.org")) {
      str := RegExReplace(str, "i)<MI>(\w+)<\/MI>", "<EM>$1</EM>")
      str := RegExReplace(str, "i)<EM>(sin|cos|tan|sec|csc|cot|exp|log|ln|mod)<\/EM>", "$1")
      str := RegExReplace(str, "i)<MSUB>.*?\K<MROW [^>]+><MN>(.*?)<\/MN><\/MROW>(?=.*?<\/MSUB>)", "<SUB>$1</SUB>")
      str := RegExReplace(str, "i)<MSUP>.*?\K<MROW [^>]+><MN>(.*?)<\/MN><\/MROW>(?=.*?<\/MSUP>)", "<SUP>$1</SUP>")
      str := RegExReplace(str, "i)<MO>([^()]+)<\/MO>", "<MO> $1 </MO>")
      str := RegExReplace(str, "i)<MO> (,|\.) <\/MO>", "<MO>$1 </MO>")
      str := RegExReplace(str, "is)<\/?MO([^>]+)?>")
    }

    ; Ilya Frank
    ; str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+COLOR: green)(?=[^>]+>)", " class=ilya-frank-translation ")

    ; Converts font-style to tags
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-style: italic)(?=[^>]+>)", " class=italic ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+font-weight: bold)(?=[^>]+>)", " class=bold ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+text-decoration: underline)(?=[^>]+>)", " class=underline ")
    str := RegExReplace(str, "is)<\w+\K\s(?=[^>]+text-decoration: overline)(?=[^>]+>)", " class=overline ")

    str := RegExReplace(str, "is)<[^>]+\K\sclass=bold class=italic(?=([^>]+)?>)", " class=italic-bold")
    str := RegExReplace(str, "is)<[^>]+\K\sclass=underline class=italic(?=([^>]+)?>)", " class=italic-underline")
    str := RegExReplace(str, "is)<[^>]+\K\sclass=underline class=bold(?=([^>]+)?>)", " class=bold-underline")
    str := RegExReplace(str, "is)<[^>]+\K\sclass=overline class=italic(?=([^>]+)?>)", " class=italic-overline")
    str := RegExReplace(str, "is)<[^>]+\K\sclass=overline class=bold(?=([^>]+)?>)", " class=bold-overline")
    str := RegExReplace(str, "is)<[^>]+\K\sclass=overline class=underline(?=([^>]+)?>)", " class=underline-overline")

    ; For Dummies books
    ; str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?class=zcheltitalic(?=([^>]+)?>)", " class=italic")

    ; Styles and fonts
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style='.*?'(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(zzz)?style=[^>]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<\/?(zzz)?(font|form)([^>]+)?>")

    ; SuperMemo uses IE7; svg was introduced in IE9
    str := RegExReplace(str, "is)<\/?(svg|path)([^>]+)?>")
    str := StrReplace(str, "https://wikimedia.org/api/rest_v1/media/math/render/svg/", "https://wikimedia.org/api/rest_v1/media/math/render/png/")

    ; Scripts
    str := RegExReplace(str, "is)<(zzz)?iframe([^>]+)?>.*?<\/(zzz)?iframe>")
    str := RegExReplace(str, "is)<(zzz)?button([^>]+)?>.*?<\/(zzz)?button>")
    str := RegExReplace(str, "is)<(zzz)?script([^>]+)?>.*?<\/(zzz)?script>")
    str := RegExReplace(str, "is)<(zzz)?input([^>]+)?>")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout|onfocus)="".*?""(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(bgcolor|onerror|onload|onclick|onmouseover|onmouseout|onfocus)=[^ >]+(?=([^>]+)?>)")
    str := RegExReplace(str, "is)<[^>]+\K\s(onmouseover|onmouseout)=[^;]+;(?=([^>]+)?>)")

    ; Unwanted tags
    str := RegExReplace(str, "is)<\/?(math)([^>]+)?>")  ; mostly from Wikipedia

    ; Remove empty paragraphs
    str := RegExReplace(str, "is)<p([^>]+)?>(&nbsp;|\s| )+<\/p>")
    str := RegExReplace(str, "is)<div([^>]+)?>(&nbsp;|\s| )+<\/div>")

    v := 1
    while (v)  ; remove <div></div>
      str := RegExReplace(str, "is)<div([^>]+)?>(\n+)?<\/div>",, v)

    if (SMSplit)
      str := StrReplace(str, SMSplitPlaceHolder, SMSplit)

    return str
  }

  LinkConcepts(aTags, wSMElWind:="ahk_class TElWind", wForeground:="") {
    loop % aTags.MaxIndex()
      this.LinkConcept(aTags[A_Index], wSMElWind, wForeground)
  }

  UnLinkConcepts(aTags, wSMElWind:="ahk_class TElWind", wForeground:="") {
    loop % aTags.MaxIndex()
      this.UnLinkConcept(aTags[A_Index], wSMElWind, wForeground)
  }

  RegAltR(WinTitle:="") {
    Acc_Get("Object", "4.5.4.6.4",, WinTitle).accDoDefaultAction()
  }

  RegInsert(WinTitle:="") {
    Acc_Get("Object", "4.5.4.8.4",, WinTitle).accDoDefaultAction()
  }

  RegAltG(WinTitle:="") {
    Acc_Get("Object", "4.5.4.2.4",, WinTitle).accDoDefaultAction()
  }

  PrevComp() {
    this.ActivateElWind()
    Send !{f12}fl
  }

  DetachTemplate() {
    this.ActivateElWind()
    Send !{f10}td
  }

  LinkContents() {
    this.ActivateElWind()
    Send !{f10}ci
  }

  ViewFile() {  ; = f9 but doesn't always work, so invoking from !{f12} is the most reliable
    this.ActivateElWind()
    Send !{f12}fv
  }

  RegMember(PostMsg:=false) {
    if (PostMsg) {
      if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
        this.PostMsg(929, true)
      } else {
        this.PostMsg(923, true)
      }
    } else {
      this.ActivateElWind()
      Send !{f12}kr
    }
  }

  GoToEl(ElNumber, WinWait:=false, ForceBG:=false) {
    if (WinActive("ahk_class TElWind") && !ForceBG) {
      this.PostMsg(769, true)
      if (!WinWait) {
        Send % "{text}" . ElNumber
        Send {Enter}
      } else {
        WinWaitActive, ahk_class TInputDlg
        ControlSetText, TMemo1, % ElNumber
        ControlSend, TMemo1, {Enter}
      }
    } else if (WinExist("ahk_class TElWind") || ForceBG) {
      this.PostMsg(769, true)
      WinWait, % "ahk_class TInputDlg ahk_pid " . WinGet("PID", "ahk_class TElWind")
      ControlSetText, TMemo1, % ElNumber
      ControlSend, TMemo1, {Enter}
    }
  }

  IsPrioInputBox() {
    return (WinActive("ahk_class #32770") && IfContains(WinGet("ProcessName"), "AutoHotkey", true) && (ControlGetText("Static1") == "Enter priority:"))
  }

  IsCtrlNYT(Text) {
    return (RegExMatch(Text, "(?:youtube\.com).*?(?:v=)([a-zA-Z0-9_-]{11})", v) && IsUrl(Text))
  }

  Duplicate() {
    Send !d
  }

  FindMatchTitleColl(TargetTitle) {
    WinGet, pahSMElWind, List, ahk_class TElWind
    loop % pahSMElWind {
      SMTitle := WinGetTitle(wTemp := "ahk_id " . pahSMElWind%A_Index%)
      TempTitle := RegExReplace(TargetTitle, "\.\.\.?", ".")  ; SM uses "." instead of "..." in titles
      if (((SMTitle ~= " \.$") && (InStr(TempTitle, RegExReplace(SMTitle, " \.$")) == 1)) || (SMTitle == TempTitle))
        return wTemp
    }
  }

  CanMarkOrExtract(HTMLExist, auiaText, Marker, ThisLabel, Label) {
    if (!HTMLExist || (!this.IsHTMLEmpty(auiaText) && !Marker) || (Marker && !IfIn(this.IsCompMarker(Marker), "read point,page mark"))) {
      if (ThisLabel != Label) {
        if (HTMLExist)
          ParentElNumber := this.GetParentElNumber(auiaText)
        MBText := "Go to source and try again?"
        if (HTMLExist)
          MBText .= " (press no to execute in current topic)"
        if (IfIn(MB := MsgBox(3,, MBText), "yes,no")) {
          if (MB = "Yes") {
            if (HTMLExist) {
              this.GoToEl(ParentElNumber)
            } else {
              this.ClickElWindSourceBtn()
            }
          }
          if !((MB = "No") && !HTMLExist) {
            this.WaitFileLoad()
            return -1
          }
        }
      }
      SetToolTip("Copied text.")
      return 0
    }
    return 1
  }

  CtrlF3() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(150)
    } else {
      this.PostMsg(151)
    }
  }

  ContentsWindow() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(310)
    } else {
      this.PostMsg(312)
    }
  }

  ReferenceRegistry() {
    if (WinGet("ProcessName", "ahk_class TElWind") == "sm19.exe") {
      this.PostMsg(161)
    } else {
      this.PostMsg(162)
    }
  }

  SetRefReg(RefRegName) {
    if (!RefRegName)
      return
    this.PostMsg(659, true)  ; link reference
    WinWait, % "ahk_class TRegistryForm ahk_pid " . WinGet("PID", "ahk_class TElWind")
    this.SetText("Edit1", RefRegName)
    ControlSend, Edit1, {Enter}
  }
}
