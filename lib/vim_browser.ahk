class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
  }

  Clear() {
    this.title := this.url := this.source := this.date := this.VidTime := this.comment := this.VidSite := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true) {
    this.clear()
    if (RestoreClip)
      ClipSaved := ClipboardAll
    this.GetUrl(0, false)
    this.GetTitleSourceDate(false, CopyFullPage)
    if (RestoreClip)
      Clipboard := ClipSaved
  }

  ParseUrl(url) {
    url := RegExReplace(url, "#.*")
    if (InStr(url, "youtube.com/watch")) {
      url := StrReplace(url, "app=desktop&")
      url := RegExReplace(url, "&.*")
    } else if (InStr(url, "bilibili.com/video")) {
      url := RegExReplace(url, "(\?(?!p=[0-9]+)|&).*")
    } else if (InStr(url, "netflix.com/watch")) {
      url := RegExReplace(url, "\?trackId=.*")
    } else if (InStr(url, "baike.baidu.com")) {
      url := RegExReplace(url, "\?.*")
    }
    return url
  }

  GetTitleSourceDate(RestoreClip:=true, CopyFullPage:=true) {
    this.Title := this.RemoveBrowserName(WinGetTitle())
    this.VidSite := this.IsVidSite(this.title)
    if (!this.url)
      this.url := this.GetAddressBarUrl()

    ; Sites that have source in their title
    if (RegExMatch(this.Title, "^很帅的日报")) {
      this.Date := RegExReplace(this.Title, "^很帅的日报 ")
      this.Title := "很帅的日报"
    } else if (RegExMatch(this.title, "^Frontiers \| ")) {
      this.source := "Frontiers"
      this.title := RegExReplace(this.title, "^Frontiers \| ")
    } else if (RegExMatch(this.title, "^NIMH » ")) {
      this.source := "NIMH"
      this.title := RegExReplace(this.title, "^NIMH » ")
    } else if (RegExMatch(this.title, "^Discord \| ")) {
      this.source := "Discord"
      this.title := RegExReplace(this.title, "^Discord \| ")

    } else if (RegExMatch(this.Title, "_百度百科$")) {
      this.Source := "百度百科"
      this.Title := RegExReplace(this.Title, "_百度百科$")
    } else if (RegExMatch(this.Title, "_百度知道$")) {
      this.Source := "百度知道"
      this.Title := RegExReplace(this.Title, "_百度知道$")
    } else if (RegExMatch(this.Title, "-新华网$")) {
      this.Source := "新华网"
      this.Title := RegExReplace(this.Title, "-新华网$")
    } else if (RegExMatch(this.title, ": MedlinePlus Medical Encyclopedia$")) {
      this.source := "MedlinePlus Medical Encyclopedia"
      this.title := RegExReplace(this.title, ": MedlinePlus Medical Encyclopedia$")
    } else if (RegExMatch(this.title, " - supermemo\.guru$")) {
      this.source := "SuperMemo Guru"
      this.title := RegExReplace(this.title, " - supermemo\.guru$")
    } else if (RegExMatch(this.title, " -- ScienceDaily$")) {
      this.source := "ScienceDaily"
      this.title := RegExReplace(this.title, " -- ScienceDaily$")
    } else if (RegExMatch(this.title, "_英为财情Investing.com$")) {
      this.source := "英为财情"
      this.title := RegExReplace(this.title, "_英为财情Investing.com$")
    } else if (RegExMatch(this.title, " \| OSUCCC - James$")) {
      this.source := "OSUCCC - James"
      this.title := RegExReplace(this.title, " \| OSUCCC - James$")

    } else if (InStr(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", Source)
      this.source := source
      this.Title := RegExReplace(this.Title, " : " . StrReplace(Source, "r/") . "$")

    ; Sites that don't include source in the title
    } else if (InStr(this.Url, "dailystoic.com")) {
      this.Source := "Daily Stoic"
    } else if (InStr(this.Url, "healthline.com")) {
      this.Source := "Healthline"
    } else if (InStr(this.Url, "webmd.com")) {
      this.Source := "WebMD"
    } else if (InStr(this.Url, "medicalnewstoday.com")) {
      this.Source := "Medical News Today"
    } else if (InStr(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
    } else if (InStr(this.Url, "github.com")) {
      this.Source := "Github"
    } else if (InStr(this.Url, "universityhealthnews.com")) {
      this.source := "University Health News"
    } else if (InStr(this.url, "verywellmind.com")) {
      this.source := "Verywell Mind"
    } else if (InStr(this.url, "cliffsnotes.com")) {
      this.source := "CliffsNotes"
    } else if (InStr(this.url, "w3schools.com")) {
      this.source := "W3Schools"
    } else if (InStr(this.url, "news-medical.net")) {
      this.source := "News-Medical"

    ; Sites that should be skipped
    } else if (IfContains(this.Url, "mp.weixin.qq.com,blackrock.com")) {
      return

    ; Sites that require special attention
    } else if (RegExMatch(this.title, " - YouTube$")) {
      this.source := "YouTube"
      this.title := RegExReplace(this.title, " - YouTube$")
      if (CopyFullPage && text := this.GetFullPage(" - YouTube", RestoreClip)) {
        this.VidTime := this.MatchYTTime(text)
        this.date := this.MatchYTDate(text)
        this.source .= ": " . this.MatchYTSource(text)
      }
    } else if (RegExMatch(this.Title, "_哔哩哔哩_bilibili$")) {
      this.Source := "哔哩哔哩"
      this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (CopyFullPage && text := this.GetFullPage("_哔哩哔哩_bilibili", RestoreClip)) {
        this.VidTime := this.MatchBLTime(text)
        this.date := this.MatchBLDate(text)
        this.source .= "：" . this.MatchBLSource(text)
      }

    ; Try to use - or | to find source
    } else {
      ReversedTitle := StrReverse(this.Title)
      if (InStr(ReversedTitle, " | ")
       && (!InStr(ReversedTitle, " - ")
        || InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - "))) {  ; used to find source
        separator := " | "
      } else if (InStr(ReversedTitle, " - ")) {
        separator := " - "
      } else if (InStr(ReversedTitle, " – ")) {
        separator := " – "  ; sites like BetterExplained
      } else if (InStr(ReversedTitle, " — ")) {
        separator := " — "
      }
      pos := separator ? InStr(StrReverse(this.Title), separator) : 0
      if (pos) {
        this.Source := SubStr(this.Title, StrLen(this.Title) - pos - 1, StrLen(this.Title))
        if (InStr(this.Source, separator))
          this.Source := StrReplace(this.Source, separator,,, 1)
        this.Title := SubStr(this.Title, 1, StrLen(this.Title) - pos - 2)
      }
    }
  }

  GetFullPage(title:="", RestoreClip:=true, ClickMore:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (RestoreClip)
      ClipSaved := ClipboardAll
    if (BL := RegExMatch(title, "_哔哩哔哩_bilibili$")) {
      send ^{home}
      MouseGetPos, XSaved, YSaved
      MouseMove, % A_ScreenWidth / 2, % A_ScreenHeight / 2
    }
    ; if (ClickMore && YT := RegExMatch(title, " - YouTube$")) {
    ;   if (Button := this.GetYTShowMoreButton())
    ;     Button.Click(400)
    ; }
    global WinClip
    WinClip.Clear()
    send {esc 2}^a^{ins}{esc}
    ClipWait 2
    text := Clipboard
    if (BL)
      MouseMove, XSaved, YSaved
    if (YT)
      send ^{home}
    if (RestoreClip)
      Clipboard := ClipSaved
    return text
  }

  GetSecFromTime(TimeStamp) {
    TimeArr := StrSplit(TimeStamp, ":")
    TimeArr := RevArr(TimeArr)
    TimeArr[3] := TimeArr[3] ? TimeArr[3] : 0
    return (TimeArr[1] + TimeArr[2] * 60 + TimeArr[3] * 3600)
  }

  GetAddressBarUrl(method:=0) {
    if (method) {
      cUIA := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      return cUIA.GetCurrentURL(true)
    } else {
      hwnd := hwnd ? hwnd : WinGet()
      if (browser = "chrome" || WinActive("ahk_exe chrome.exe")) {
        accAddressBar := Acc_Get("Object", "4.1.1.2.1.2.5.3",, "ahk_id " . hwnd)
      } else if (browser = "edge" || WinActive("ahk_exe msedge.exe")) {
        accAddressBar := Acc_Get("Object", "4.1.1.4.1.2.5.4",, "ahk_id " . hwnd)
      }
      return accAddressBar.accValue(0)
    }
  }

  GetVidTime(title:="", FullPageText:="", RestoreClip:=true) {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    if (!this.IsVidSite(title))
      return
    if (RestoreClip)
      ClipSaved := ClipboardAll
    global WinClip
    WinClip.Clear()
    FullPageText := FullPageText ? FullPageText : this.GetFullPage(title, false, false)
    if (RegExMatch(title, " - YouTube$")) {
      VidTime := this.MatchYTTime(FullPageText)
    } else if (RegExMatch(title, "_哔哩哔哩_bilibili$")) {
      VidTime := this.MatchBLTime(FullPageText)
    }
    if (RestoreClip)
      Clipboard := ClipSaved
    return this.VidTime := VidTime
  }

  GetUrl(method:=0, RestoreClip:=true) {
    if (!method) {
      this.title := this.title ? this.title : this.RemoveBrowserName(WinGetTitle())
      if (this.title = "New Tab")
        return
      send {f6}^l  ; go to address bar
      if (RestoreClip)
        ClipSaved := ClipboardAll
      global WinClip
      WinClip.Clear()
      while (!Clipboard)
        send ^l^c
      this.url := this.ParseUrl(Clipboard)
      send {esc}
      if (RestoreClip)
        Clipboard := ClipSaved
      return this.url
    } else {
      cUIA := new UIA_Browser("ahk_exe " . WinGet("ProcessName"))
      url := cUIA.GetCurrentURL()
      return this.url := this.ParseUrl(url)
    }
  }

  MatchYTTime(text) {
    RegExMatch(text, "\r\n\K[0-9:]+(?= \/ )", VidTime)
    return VidTime
  }

  MatchYTSource(text) {
    ; RegExMatch(text, "i)SAVE(\r\n){3}\K.*", YTSource)
    RegExMatch(text, ".*(?=\r\n.*subscribers)", YTSource)
    return YTSource
  }

  MatchYTDate(text) {
    RegExMatch(text, "views +?((Streamed live|Premiered) on )?\K[0-9]+ \w+ [0-9]+", date)
    return date
  }

  MatchBLTime(text) {
    RegExMatch(text, "\r\n\K[0-9:]+(?= \/ )", VidTime)
    return VidTime
  }

  MatchBLSource(text) {
    RegExMatch(text, "m)^.*(?=\r\n 发消息)", BLSource)
    return BLSource
  }

  MatchBLDate(text) {
    RegExMatch(text, "\n\K[0-9]{4}-[0-9]{2}-[0-9]{2}", date)
    return date
  }

  RunInIE(url) {
    ie := ComObjCreate("InternetExplorer.Application")
    ie.Visible := true
    ie.Navigate(url)
  }

  RemoveBrowserName(title) {
    return RegExReplace(title, "( - Google Chrome| — Mozilla Firefox|( and [0-9]+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
  }

  IsVidSite(title:="") {
    title := title ? title : this.RemoveBrowserName(WinGetTitle())
    return RegExMatch(title, "( - YouTube|_哔哩哔哩_bilibili)$")
  }

  Highlight() {
    send !+h  ; more robust than ControlSend
    sleep 20
  }

  GetYTShowMoreButton(BrowserExe:="") {
    this.url := this.url ? this.url : this.GetAddressBarUrl()
    if (!InStr(this.url, "youtube.com/watch"))
      return
    BrowserExe := BrowserExe ? BrowserExe : WinGet("ProcessName")
    cUIA := new UIA_Browser("ahk_exe " . BrowserExe)
    if (!Button := cUIA.FindFirstBy("ControlType=Button AND Name='Show more' AND AutomationId='expand'"))
      Button := cUIA.FindFirstBy("ControlType=Text AND Name='Show more'")
    return Button
  }
}