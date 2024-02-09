#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Clip() - Send and Retrieve Text Using the Clipboard
; Originally by berban - updated February 18, 2019 - modified by Winston
; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62156
Clip(Text:="", Reselect:=false, RestoreClip:=true, HTML:=false, KeysToSend:="", WaitTime:=-1) {
  global WinClip, Vim
  if (RestoreClip)
    ClipSaved := ClipboardAll
  If (Text = "") {
    LongCopy := A_TickCount, WinClip.Clear(), LongCopy -= A_TickCount  ; LongCopy gauges the amount of time it takes to empty the clipboard which can predict how long the subsequent ClipWait will need
    send % KeysToSend ? KeysToSend : "^c"
    if (WaitTime == -1) {
      ClipWait, % LongCopy ? 0.6 : 0.2, True
    } else if (WaitTime == 0) {
      ClipWait,, True
    } else if (WaitTime) {
      ClipWait, % WaitTime, True
    }
    if (!ErrorLevel) {
      if (HTML) {
        ClipboardGet_HTML(Clipped)
        RegExMatch(Clipped, "s)<!--StartFragment-->\K.*(?=<!--EndFragment-->)", Clipped)
      } else {
        Clipped := Clipboard
      }
    }
  } Else {
    if (HTML && (HTML != "sm")) {
      SetClipboardHTML(text)
    } else {
      Clipboard := Text
    }
    if (HTML = "sm") {
      Vim.SM.PasteHTML()
    } else {
      send % KeysToSend ? KeysToSend : "^v"
      while (DllCall("GetOpenClipboardWindow")) {
        Critical
        sleep 20
      }
    }
  }
  If (Text && Reselect)
    send % "+{Left " . StrLen(Vim.ParseLineBreaks(text)) . "}"
  if (RestoreClip)  ; for scripts that restore clipboard at the end
    Clipboard := ClipSaved
  If (Text = "")
    Return Clipped
}

Copy(RestoreClip:=true, HTML:=false, KeysToSend:="", WaitTime:=-1) {
  return Clip(,, RestoreClip, HTML, KeysToSend, WaitTime)
}
