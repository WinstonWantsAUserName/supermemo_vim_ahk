﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
class VimBrowser {
  __New(Vim) {
    this.Vim := Vim
  }

  Clear() {
    ; DO NOT add critical here
    this.Title := this.Url := this.Source := this.Date := this.Comment := this.TimeStamp := this.Author := this.FullTitle := ""
    global guiaBrowser := ""
  }

  GetInfo(RestoreClip:=true, CopyFullPage:=true, ClickBtn:=true) {
    this.ActivateBrowser()
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    this.Url := this.GetParsedUrl()
    if (ClickBtn)
      this.ClickBtn()
    this.GetTitleSourceDate(RestoreClip, CopyFullPage)
  }

  ParseUrl(url) {
    PoundSymbList := "wiktionary.org/wiki,workflowy.com,korean.dict.naver.com/koendict"
    if (!IfContains(url, PoundSymbList))
      url := RegExReplace(url, "#.*")
    ; Remove everything after "?"
    QuestionMarkList := "baike.baidu.com,bloomberg.com,substack.com"
    if (IfContains(url, QuestionMarkList)) {
      url := RegExReplace(url, "\?.*")
    } else if (IfContains(url, "youtube.com/watch")) {
      url := StrReplace(url, "app=desktop&"), url := RegExReplace(url, "&.*")
    } else if (IfContains(url, "bilibili.com")) {
      url := RegExReplace(url, "(\?(?!p=\d+)|&).*")
      url := RegExReplace(url, "\/(?=\?p=\d+)")
    } else if (IfContains(url, "netflix.com/watch")) {
      url := RegExReplace(url, "\?trackId=.*")
    } else if (IfContains(url, "finance.yahoo.com")) {
      url := RegExReplace(url, "\?.*")
      if !(url ~= "\/$")
        url := url . "/"
    } else if (IfContains(url, "dle.rae.es")) {
      url := StrReplace(url, "?m=form")
    }
    return url
  }

  GetTitleSourceDate(RestoreClip:=true, CopyFullPage:=true, FullPageText:="", GetUrl:=true, GetDate:=true, GetTimeStamp:=true) {
    this.FullTitle := this.FullTitle ? this.FullTitle : this.GetFullTitle()
    this.Title := this.FullTitle
    if (GetUrl)
      this.Url := this.Url ? this.Url : this.GetParsedUrl()

    if (this.Title ~= " - YouTube$")
      this.Title := RegExReplace(this.Title, "^\(\d+\) ")

    ; Sites that should be skipped
    SkippedList := "wind.com.cn,thepokerbank.com,tutorial.math.lamar.edu"
    if (IfContains(this.Url, SkippedList)) {
      return

    ; Sites that have source in their title
    } else if (this.Title ~= "^很帅的日报") {
      this.Date := RegExReplace(this.Title, "^很帅的日报 "), this.Title := "很帅的日报"
    } else if (this.Title ~= "^Frontiers \| ") {
      this.Source := "Frontiers", this.Title := RegExReplace(this.Title, "^Frontiers \| ")
    } else if (this.Title ~= "^NIMH » ") {
      this.Source := "NIMH", this.Title := RegExReplace(this.Title, "^NIMH » ")
    } else if (this.Title ~= "^(• )?Discord \| ") {
      this.Title := RegExReplace(this.Title, "^(• )?Discord \| "), RegexMatch(this.Title, "^.* \| (.*)$", v), this.Source := "Discord: " . v1
      this.Title := RegexReplace(this.Title , "^.*\K \| .*$")
    } else if (this.Title ~= "^italki - ") {
      this.Source := "italki", this.Title := RegExReplace(this.Title, "^italki - ")
    } else if (this.Title ~= "^CSOP - Products - ") {
      this.Source := "CSOP Asset Management", this.Title := RegExReplace(this.Title, "^CSOP - Products - ")
    } else if (this.Title ~= "^ArtStation - ") {
      this.Source := "ArtStation", this.Title := RegExReplace(this.Title, "^ArtStation - ")
    } else if (this.Title ~= "^Art... When I Feel Like It - ") {
      this.Source := "Art... When I Feel Like It ", this.Title := RegExReplace(this.Title, "^Art... When I Feel Like It - ")
    } else if (this.Title ~= "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ") {
      this.Author := "Henry George Liddell, Robert Scott", this.Source := "An Intermediate Greek-English Lexicon", this.Title := RegExReplace(this.Title, "^Henry George Liddell, Robert Scott, An Intermediate Greek-English Lexicon, ")
    } else if (RegExMatch(this.Title, "i)^The Project Gutenb(?:e|u)rg eBook of (.*?),? by (.*?)\.?$", v)) {
      this.Author := v2, this.Source := "Project Gutenberg", this.Title := v1

    } else if (this.Title ~= "_百度知道$") {
      this.Source := "百度知道", this.Title := RegExReplace(this.Title, "_百度知道$")
    } else if (this.Title ~= "-新华网$") {
      this.Source := "新华网", this.Title := RegExReplace(this.Title, "-新华网$")
    } else if (this.Title ~= ": MedlinePlus Medical Encyclopedia$") {
      this.Source := "MedlinePlus Medical Encyclopedia", this.Title := RegExReplace(this.Title, ": MedlinePlus Medical Encyclopedia$")
    } else if (this.Title ~= "_英为财情Investing.com$") {
      this.Source := "英为财情", this.Title := RegExReplace(this.Title, "_英为财情Investing.com$")
    } else if (this.Title ~= " \| OSUCCC - James$") {
      this.Source := "OSUCCC - James", this.Title := RegExReplace(this.Title, " \| OSUCCC - James$")
    } else if (this.Title ~= " · GitBook$") {
      this.Source := "GitBook", this.Title := RegExReplace(this.Title, " · GitBook$")
    } else if (this.Title ~= " \| SLEEP \| Oxford Academic$") {
      this.Source := "SLEEP | Oxford Academic", this.Title := RegExReplace(this.Title, " \| SLEEP \| Oxford Academic$")
    } else if (this.Title ~= " \| Microbiome \| Full Text$") {
      this.Source := "Microbiome", this.Title := RegExReplace(this.Title, " \| Microbiome \| Full Text$")
    } else if (this.Title ~= "-清华大学医学院$") {
      this.Source := "清华大学医学院", this.Title := RegExReplace(this.Title, "-清华大学医学院$")
    } else if (this.Title ~= "- 雪球$") {
      this.Source := "雪球", this.Title := RegExReplace(this.Title, "- 雪球$")
    } else if (this.Title ~= " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$") {
      this.Source := "SuperDataScience", this.Title := RegExReplace(this.Title, " - Podcasts - SuperDataScience \| Machine Learning \| AI \| Data Science Career \| Analytics \| Success$")
    } else if (this.Title ~= " \| Definición \| Diccionario de la lengua española \| RAE - ASALE$") {
      this.Source := "Diccionario de la lengua española | RAE - ASALE", this.Title := RegExReplace(this.Title, " \| Diccionario de la lengua española \| RAE - ASALE$")
    } else if (this.Title ~= " • Zettelkasten Method$") {
      this.Source := "Zettelkasten Method", this.Title := RegExReplace(this.Title, " • Zettelkasten Method$")
    } else if (this.Title ~= " on JSTOR$") {
      this.Source := "JSTOR", this.Title := RegExReplace(this.Title, " on JSTOR$")
    } else if (this.Title ~= " - Queensland Brain Institute - University of Queensland$") {
      this.Source := "Queensland Brain Institute - University of Queensland", this.Title := RegExReplace(this.Title, " - Queensland Brain Institute - University of Queensland$")
    } else if (this.Title ~= " \| BMC Neuroscience \| Full Text$") {
      this.Source := "BMC Neuroscience", this.Title := RegExReplace(this.Title, " \| BMC Neuroscience \| Full Text$")
    } else if (this.Title ~= " \| MIT News \| Massachusetts Institute of Technology$") {
      this.Source := "MIT News | Massachusetts Institute of Technology", this.Title := RegExReplace(this.Title, " \| MIT News \| Massachusetts Institute of Technology$")
    } else if (this.Title ~= " - StatPearls - NCBI Bookshelf$") {
      this.Source := "StatPearls - NCBI Bookshelf", this.Title := RegExReplace(this.Title, " - StatPearls - NCBI Bookshelf$")
    } else if (this.Title ~= "：剑桥词典$") {
      this.Source := "剑桥词典", this.Title := RegExReplace(this.Title, "：剑桥词典$")
    } else if (this.Title ~= " - The Skeptic's Dictionary - Skepdic\.com$") {
      this.Source := "The Skeptic's Dictionary", this.Title := RegExReplace(this.Title, " - The Skeptic's Dictionary - Skepdic\.com$")
    } else if (this.Title ~= "-格隆汇$") {
      this.Source := "格隆汇", this.Title := RegExReplace(this.Title, "-格隆汇$")
    } else if (this.Title ~= "：劍橋詞典$") {
      this.Source := "劍橋詞典", this.Title := RegExReplace(this.Title, "：劍橋詞典$")
    } else if (this.Title ~= " - Treccani - Treccani - Treccani$") {
      this.Source := "Treccani", this.Title := RegExReplace(this.Title, " - Treccani - Treccani - Treccani$")

    } else if (RegExMatch(this.Title, " \| (.*) \| Cambridge Core$", v)) {
      this.Source := v1 . " | Cambridge Core", this.Title := RegExReplace(this.Title, "\| (.*) \| Cambridge Core$")
    } else if (RegExMatch(this.Title, " \| (.*) \| The Guardian$", v)) {
      this.Source := v1 . " | The Guardian", this.Title := RegExReplace(this.Title, " \| (.*) \| The Guardian$")
    } else if (RegExMatch(this.Title, " - (.*) \| OpenStax$", v)) {
      this.Source := v1 . " | OpenStax", this.Title := RegExReplace(this.Title, " - (.*) \| OpenStax$")
    } else if (RegExMatch(this.Title, " : Free Download, Borrow, and Streaming : Internet Archive$", v)) {
      this.Source := "Internet Archive", this.Title := RegExReplace(this.Title, "( : .*?)? : Free Download, Borrow, and Streaming : Internet Archive$")
      if (RegexMatch(this.FullTitle, " : (.*?) : Free Download, Borrow, and Streaming : Internet Archive$", v))
        this.Author := v1
    } else if (RegExMatch(this.Title, " \| a podcast by (.*)$", v)) {
      this.Author := v1, this.Source := "PodBean", this.Title := RegExReplace(this.Title, " \| a podcast by (.*)$")
    } else if (IfContains(this.Url, "podbean.com")) {
      this.Source := "PodBean"
      RegExMatch(this.Title, " \| (.*?)$", v), this.Author := v1
      this.Title := RegExReplace(this.Title, " \| (.*?)$")
      if (IfContains(this.Url, "podbean.com/e") && CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (GetDate)
          RegExMatch(FullPageText, "(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) \d{2}`, \d{4}", v), this.Date := v
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(FullPageText)
      }

    } else if (RegExMatch(this.Title, " \| (.*) \| Fandom$", v)) {
      this.Source := v1 . " | Fandom", this.Title := RegExReplace(this.Title, " \| (.*) \| Fandom$")
      if (GetDate) {
        this.Url := this.Url ? this.Url : this.GetParsedUrl()
        TempPath := A_Temp . "\" . GetCurrTimeForFileName() . ".htm"
        UrlDownloadToFile, % this.Url . "?action=history", % TempPath
        t := FileRead(TempPath)
        RegExMatch(t, "<h4 class=""mw-index-pager-list-header-first mw-index-pager-list-header"">(.*?)<\/h4>", v)
        this.Date := v1
      }
    } else if (this.Title ~= " - TV Tropes$") {
      this.Source := "TV Tropes", this.Title := RegExReplace(this.Title, " - TV Tropes$")
      if (GetDate) {
        this.Url := this.Url ? this.Url : this.GetParsedUrl()
        TempPath := A_Temp . "\" . GetCurrTimeForFileName() . ".htm"
        RegExMatch(this.Url, "https:\/\/tvtropes\.org\/pmwiki\/pmwiki\.php\/(.*?)\/(.*?)($|\?)", v)
        DLUrl := "https://tvtropes.org/pmwiki/article_history.php?article=" . v1 . "." . v2
        UrlDownloadToFile, % DLUrl, % TempPath
        t := FileRead(TempPath)
        RegExMatch(t, "<a href=""\/pmwiki\/article_history\.php\?article=" . v1 . "\." . v2 . ".*?#edit.*?>(\w+ \d+\w+ \d+)", v)
        this.Date := v1
      }

    } else if (this.Title ~= " \/ X$") {
      this.Source := "X", this.Title := RegExReplace(this.Title, """ \/ X$")
      RegExMatch(this.Title, "^(.*) on X: """, v), this.Author := v1
      this.Title := RegExReplace(this.Title,  "^.* on X: """)

    } else if (RegExMatch(this.Title, " \| by (.*?) \| ((.*?) \| )?Medium$", v)) {
      this.Source := "Medium", this.Title := RegExReplace(this.Title, " \| by .*? \| Medium$"), this.Author := v1

    } else if (RegExMatch(this.Title, "^Git - (.*?) Documentation$", v)) {
      this.Source := "Git - Documentation", this.Title := v1

    } else if (RegExMatch(this.Title, "'(.*?)': Naver Korean-English Dictionary", v)) {
      this.Source := "Naver Korean-English Dictionary", this.Title := v1

    } else if (IfContains(this.Url, "reddit.com")) {
      RegExMatch(this.Url, "reddit\.com\/\Kr\/[^\/]+", v), this.Source := v, this.Title := RegExReplace(this.Title, " : " . StrReplace(v, "r/") . "$")

    } else if (IfContains(this.Url, "podcasts.google.com")) {
      RegExMatch(this.Title, "^(.*) - ", v), this.Author := v1, this.Title := RegExReplace(this.Title, "^(.*) - "), this.Source := "Google Podcasts"

    ; Sites that don't include source in the title
    } else if (IfContains(this.Url, "dailystoic.com")) {
      this.Source := "Daily Stoic"
    } else if (IfContains(this.Url, "healthline.com")) {
      this.Source := "Healthline"
    } else if (IfContains(this.Url, "webmd.com")) {
      this.Source := "WebMD"
    } else if (IfContains(this.Url, "medicalnewstoday.com")) {
      this.Source := "Medical News Today"
    } else if (IfContains(this.Url, "universityhealthnews.com")) {
      this.Source := "University Health News"
    } else if (IfContains(this.Url, "verywellmind.com")) {
      this.Source := "Verywell Mind"
    } else if (IfContains(this.Url, "cliffsnotes.com")) {
      this.Source := "CliffsNotes", this.Title := RegExReplace(this.Title, " \| CliffsNotes$")
    } else if (IfContains(this.Url, "w3schools.com")) {
      this.Source := "W3Schools"
    } else if (IfContains(this.Url, "news-medical.net")) {
      this.Source := "News-Medical"
    } else if (IfContains(this.Url, "ods.od.nih.gov")) {
      this.Source := "National Institutes of Health: Office of Dietary Supplements"
    } else if (IfContains(this.Url, "vandal.elespanol.com")) {
      this.Source := "Vandal"
    } else if (IfContains(this.Url, "fidelity.com")) {
      this.Source := "Fidelity International"
    } else if (IfContains(this.Url, "eliteguias.com")) {
      this.Source := "Eliteguias"
    } else if (IfContains(this.Url, "byjus.com")) {
      this.Source := "BYJU'S"
    } else if (IfContains(this.Url, "blackrock.com")) {
      this.Source := "BlackRock"
    } else if (IfContains(this.Url, "growbeansprout.com")) {
      this.Source := "Beansprout"
    } else if (IfContains(this.Url, "researchgate.net")) {
      this.Source := "ResearchGate"
    } else if (IfContains(this.Url, "neuroscientificallychallenged.com")) {
      this.Source := "Neuroscientifically Challenged"
    } else if (IfContains(this.Url, "bachvereniging.nl")) {
      this.Source := "Netherlands Bach Society"
    } else if (IfContains(this.Url, "tutorialspoint.com")) {
      this.Source := "Tutorials Point"
    } else if (IfContains(this.Url, "fourminutebooks.com")) {
      this.Source := "Four Minute Books"
    } else if (IfContains(this.Url, "forvo.com")) {
      this.Source := "Forvo"
    } else if (IfContains(this.Url, "finty.com")) {
      this.Source := "Finty"
    } else if (IfContains(this.Url, "theconversation.com")) {
      this.Source := "The Conversation"
    } else if (IfContains(this.Url, "thefreedictionary.com")) {
      this.Source := "The Free Dictionary"
    } else if (IfContains(this.Url, "examine.com")) {
      this.Source := "Examine"
    } else if (IfContains(this.Url, "corporatefinanceinstitute.com")) {
      this.Source := "Corporate Finance Institute"
    } else if (IfContains(this.Url, "cnrtl.fr/definition")) {
      this.Source := "Trésor de la langue française informatisé"

    ; Sites that require special attention
    ; Video sites
    } else if (IfContains(this.Url, "youtube.com/watch")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle, FullPageText)
        RegExMatch(FullPageText, ".*(?=\r\n.*subscribers)", Author), this.Author := Author
        RegExMatch(FullPageText, "views +?(\r\n)?((Streamed live|Premiered) on )?\K(\d+ \w+ \d+|\w+ \d+, \d+)", Date), this.Date := Date
      }
    } else if (IfContains(this.Url, "youtube.com/playlist")) {
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")
      if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(.*)\r\n\d+ videos", Author), this.Author := Author
    } else if (this.Title ~= "_哔哩哔哩_bilibili$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "_哔哩哔哩_bilibili$")
      if (IfContains(this.Url, "bilibili.com/video")) {
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle)
        if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
          RegExMatch(FullPageText, "(.*) \d\d:\d\d:\d\d", Date), this.Date := Date
          RegExMatch(FullPageText, "m)^.*(?=\r\n 发消息)", Author), this.Author := Author
        }
      }
    } else if (this.Title ~= "-bilibili-哔哩哔哩$") {
      this.Source := "哔哩哔哩", this.Title := RegExReplace(this.Title, "-bilibili-哔哩哔哩$")
      if (this.Title ~= "-纪录片-全集-高清独家在线观看$")
        this.Source .= "：纪录片", this.Title := RegExReplace(this.Title, "-纪录片-全集-高清独家在线观看$")
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (this.Url ~= "moviesjoy\.(.*?)\/watch") {
      RegExMatch(this.Title, "^Watch (.*?) HD online$", v)
      this.Source := "MoviesJoy", this.Title := v1
      if (RegExMatch(this.Title, " (\d+)$", v))
        this.Date := v1, this.Title := RegExReplace(this.Title, " (\d+)$")
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (IfContains(this.Url, "dopebox.to")) {
      RegExMatch(this.Title, "^Watch Free (.*?) Full Movies Online$", v)
      this.Source := "DopeBox", this.Title := v1
      if (RegExMatch(this.Title, " (\d+)$", v))
        this.Date := v1, this.Title := RegExReplace(this.Title, " (\d+)$")
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (RegExMatch(this.Title, "^Watch (.*?) online free on 9anime$", v)) {
      this.Source := "9anime", this.Title := v1
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (RegExMatch(this.Title, "^Watch full (.*?) english sub \| Kissasian$", v)) {
      this.Source := "Kissasian", this.Title := v1
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (RegExMatch(this.Title, "^Watch (.*?) English Sub/Dub online Free on Aniwatch\.to$", v)) {
      this.Source := "AniWatch", this.Title := v1
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (this.Title ~= "-免费在线观看-爱壹帆$") {
      this.Source := "爱壹帆", this.Title := RegExReplace(this.Title, "-免费在线观看-爱壹帆$")
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (this.Title ~= "_高清在线观看 – NO视频$") {
      this.Source := "NO视频", this.Title := RegExReplace(this.Title, "_高清在线观看 – NO视频$")
      if (GetTimeStamp)
        this.TimeStamp := this.GetTimeStamp(this.FullTitle)
    } else if (this.Title ~= "_[^_]+ - 喜马拉雅$") {
      this.Source := "喜马拉雅", this.Title := RegExReplace(this.Title, "_[^_]+ - 喜马拉雅$")
      if (IfContains(this.Url, "ximalaya.com/sound")) {
        if (GetTimeStamp)
          this.TimeStamp := this.GetTimeStamp(this.FullTitle)
        if (CopyFullPage && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip)))) {
          RegExMatch(FullPageText, "\d{4}-\d{2}-\d{2}", Date), this.Date := Date
          RegExMatch(FullPageText, "声音主播\r\n\K.*", Author), this.Author := Author
        }
      }

    ; Wikipedia or wiki format websites
    } else if (this.Title ~= " - supermemo\.guru$") {
      this.Source := "SuperMemo Guru", this.Title := RegExReplace(this.Title, " - supermemo\.guru$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - SuperMemopedia$") {
      this.Source := "SuperMemopedia", this.Title := RegExReplace(this.Title, " - SuperMemopedia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - SuperMemo Help$") {
      this.Source := "SuperMemo Help", this.Title := RegExReplace(this.Title, " - SuperMemo Help$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Simple English Wikipedia, the free encyclopedia$") {
      this.Source := "Simple English Wikipedia", this.Title := RegExReplace(this.Title, " - Simple English Wikipedia, the free encyclopedia")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last changed on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wiktionary, the free dictionary$") {
      this.Source := "Wiktionary", this.Title := RegExReplace(this.Title, " - Wiktionary, the free dictionary$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (IfContains(this.Url, "en.wikiversity.org")) {
      this.Source := "Wikiversity", this.Title := RegExReplace(this.Title, " - Wikiversity$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikisource, the free online library$") {
      this.Source := "Wikisource", this.Title := RegExReplace(this.Title, " - Wikisource, the free online library$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Wikibooks, open books for an open world$") {
      this.Source := "Wikibooks", this.Title := RegExReplace(this.Title, " - Wikibooks, open books for an open world$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last edited on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - ProofWiki$") {
      this.Source := "ProofWiki", this.Title := RegExReplace(this.Title, " - ProofWiki$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last modified on (.*?),", v), this.Date := v1
    } else if (this.Title ~= " - Citizendium$") {
      this.Source := "Citizendium", this.Title := RegExReplace(this.Title, " - Citizendium$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "This page was last modified (.*?), (.*?)\.", v), this.Date := v2
    } else if (this.Title ~= " - 维基百科，自由的百科全书$") {
      this.Source := "维基百科", this.Title := RegExReplace(this.Title, " - 维基百科，自由的百科全书$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本页面最后修订于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基大典$") {
      this.Source := "維基大典", this.Title := RegExReplace(this.Title, " - 維基大典$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此頁(.*?) （", v), this.Date := v1
    } else if (this.Title ~= " - 維基百科，自由的百科全書$") {
      this.Source := "維基百科", this.Title := RegExReplace(this.Title, " - 維基百科，自由的百科全書$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "本頁面最後修訂於(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 維基百科，自由嘅百科全書$") {
      this.Source := "維基百科", this.Title := RegExReplace(this.Title, " - 維基百科，自由嘅百科全書$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "呢版上次改係(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基文库，自由的图书馆$") {
      this.Source := "维基文库", this.Title := RegExReplace(this.Title, " - 维基文库，自由的图书馆$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - 维基词典，自由的多语言词典$") {
      this.Source := "维基词典", this.Title := RegExReplace(this.Title, " - 维基词典，自由的多语言词典$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "此页面最后编辑于(.*?) \(", v), this.Date := v1
    } else if (this.Title ~= " - Wikipedia, la enciclopedia libre$") {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia, la enciclopedia libre$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " — Wikipédia$") {
      this.Source := "Wikipédia", this.Title := RegExReplace(this.Title, " — Wikipédia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La dernière modification de cette page a été faite .*? (\d+ .*? \d+) à", v), this.Date := v1
    } else if (this.Title ~= " - Wikcionario, el diccionario libre$") {
      this.Source := "Wikcionario", this.Title := RegExReplace(this.Title, " - Wikcionario, el diccionario libre$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Esta página se editó por última vez el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " - Viquipèdia, l'enciclopèdia lliure$") {
      this.Source := "Viquipèdia", this.Title := RegExReplace(this.Title, " - Viquipèdia, l'enciclopèdia lliure$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La pàgina va ser modificada per darrera vegada el (.*?) a ", v), this.Date := v1
    } else if (this.Title ~= " - Vicipaedia$") {
      this.Source := "Vicipaedia", this.Title := RegExReplace(this.Title, " - Vicipaedia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Novissima mutatio die (.*?) hora", v), this.Date := v1
    } else if (IfContains(this.Url, "it.wikipedia.org")) {
      this.Source := "Wikipedia", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Questa pagina è stata modificata per l'ultima volta il (.*?) alle", v), this.Date := v1
    } else if (IfContains(this.Url, "ja.wikipedia.org")) {
      this.Source := "ウィキペディア", this.Title := RegExReplace(this.Title, " - Wikipedia$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "最終更新 (.*?) \(", v), this.Date := v1
    } else if (IfContains(this.Url, "fr.wikisource.org")) {
      this.Source := "Wikisource", this.Title := RegExReplace(this.Title, " - Wikisource$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "La dernière modification de cette page a été faite le (.*?) à ", v), this.Date := v1

    } else if (IfContains(this.Url, "github.com")) {
      this.Source := "GitHub", this.Title := RegExReplace(this.Title, "^GitHub - "), this.Title := RegExReplace(this.Title, " · GitHub$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Latest commit .*? on (.*)", v), this.Date := v1

    ; Others
    } else if (this.Title ~= "_百度百科$") {
      this.Source := "百度百科", this.Title := RegExReplace(this.Title, "_百度百科$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "s)最近更新：.*（(.*)）", v), this.Date := v1
    } else if (IfContains(this.Url, "zhuanlan.zhihu.com")) {
      this.Source := "知乎", this.Title := RegExReplace(this.Title, " - 知乎$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "(编辑|发布)于 (.*?) ", v), this.Date := v2
    } else if (IfContains(this.Url, "economist.com")) {
      this.Source := "The Economist", this.Title := RegExReplace(this.Title, " \| The Economist$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "\r\n(\w+ \d+\w+ \d+)( \| .*)?\r\n\r\n", v), this.Date := v1
    } else if (IfContains(this.Url, "investopedia.com")) {
      this.Source := "Investopedia"
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Updated (.*)", v), this.Date := v1
    } else if (IfContains(this.Url, "mp.weixin.qq.com")) {
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, " ([0-9]{4}-[0-9]{2}-[0-9]{2}) ", v), this.Date := v1
    } else if (this.Title ~= " \| Britannica$") {
      this.Source := "Britannica", this.Title := RegExReplace(this.Title, " \| Britannica$")
      if (CopyFullPage && GetDate && (FullPageText || (FullPageText := this.GetFullPage(RestoreClip))))
        RegExMatch(FullPageText, "Last Updated: (.*) • ", v), this.Date := v1
      
    ; Special cases
    } else if (this.Title ~= " - YouTube$") {  ; for getting title for timestamp syncing with SM
      this.Source := "YouTube", this.Title := RegExReplace(this.Title, " - YouTube$")

    } else {
      ReversedTitle := StrReverse(this.Title)
      if (IfContains(ReversedTitle, " | ") && (!IfContains(ReversedTitle, " - ") || (InStr(ReversedTitle, " | ") < InStr(ReversedTitle, " - ")))) {
        separator := " | "
      } else if (IfContains(ReversedTitle, " – ")) {
        separator := " – "  ; sites like BetterExplained
      } else if (IfContains(ReversedTitle, " - ")) {
        separator := " - "
      } else if (IfContains(ReversedTitle, " — ")) {
        separator := " — "
      } else if (IfContains(ReversedTitle, " -- ")) {
        separator := " -- "
      } else if (IfContains(ReversedTitle, " • ")) {
        separator := " • "
      }
      if (pos := separator ? InStr(ReversedTitle, separator) : 0) {
        TitleLength := StrLen(this.Title) - pos - StrLen(separator) + 1
        this.Source := SubStr(this.Title, TitleLength + 1, StrLen(this.Title))
        this.Source := StrReplace(this.Source, separator,,, 1)
        this.Title := SubStr(this.Title, 1, TitleLength)
      }
    }
  }

  GetFullPage(RestoreClip:=true) {
    if (RestoreClip)
      ClipSaved := ClipboardAll
    this.ActivateBrowser()
    CopyAll()
    text := Clipboard
    if (RestoreClip)
      Clipboard := ClipSaved
    return text
  }

  GetSecFromTime(TimeStamp) {
    if (!TimeStamp)
      return 0
    aTime := RevArr(StrSplit(TimeStamp, ":"))
    aTime[3] := aTime[3] ? aTime[3] : 0
    return aTime[1] + aTime[2] * 60 + aTime[3] * 3600
  }

  GetParsedUrl() {
    this.ActivateBrowser()
    global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
    return this.ParseUrl(guiaBrowser.GetCurrentURL())
  }

  GetTimeStamp(Title:="", FullPageText:="", RestoreClip:=true) {
    Title := Title ? Title : this.GetFullTitle()
    this.ActivateBrowser()
    if (Title ~= " - YouTube$") {
      if (FullPageText := FullPageText ? FullPageText : this.GetFullPage(RestoreClip)) {
        RegExMatch(FullPageText, "\r\n([0-9:]+) \/ ([0-9:]+)", v)
        ; v1 = v2 means at end of video
        TimeStamp := (v1 == v2) ? "0:00" : v1
      }
    } else if (Title ~= "_[^_]+ - 喜马拉雅$") {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
      TimeStamp := guiaBrowser.FindFirstByName("^\d{2}:\d{2}:\d{2}$",, "regex").CurrentName
      TimeStamp := RegExReplace(TimeStamp, "^00:")
    } else {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
      TimeStamp := guiaBrowser.FindFirstByName("^(\d{1,2}:)?\d{1,2}:\d{1,2}$",, "regex").CurrentName
    }
    return RegExReplace(TimeStamp, "^0(?=\d)")
  }

  RunInIE(url) {
    if ((url ~= "file:\/\/") && (url ~= "#.*"))
      url := RegExReplace(url, "#.*")
    wIE := "ahk_class IEFrame ahk_exe iexplore.exe"
    if (!el := WinExist(wIE)) {
      ie := ComObjCreate("InternetExplorer.Application")
      ie.Visible := true
      ie.Navigate(url)
    } else {
      if (ControlGetText("Edit1", wIE)) {  ; current page is not new tab page
        ControlSend, ahk_parent, {Ctrl Down}t{Ctrl Up}, % wIE
        ControlTextWait("Edit1", "", wIE)
      }
      ControlSetText, Edit1, % url, % wIE
      ControlSend, Edit1, {enter}, % wIE
    }
    WinActivate, % wIE
  }

  GetFullTitle(w:="") {
    Title := w ? WinGetTitle(w) : WinGetTitle("ahk_group Browser")
    return RegExReplace(Title, "( - Google Chrome| — Mozilla Firefox|( and \d+ more pages?)? - [^-]+ - Microsoft​ Edge)$")
  }

  IsVideoOrAudioSite(Title:="", w:="") {
    Title := Title ? Title : this.GetFullTitle(w)
    if (Title ~= " - YouTube$") {
      return "yt"
    ; return 1 if time stamp can be in url and ^a covers the time stamp
    } else if (Title ~= "(_哔哩哔哩_bilibili|-bilibili-哔哩哔哩)$") {  ; time stamp can be in url but ^a doesn't cover time stamp
      return 2
    } else if (Title ~= "^(Netflix|Watch full .*? english sub \| Kissasian|Watch .*? HD online|Watch Free .*? Full Movies Online|Watch .*? online free on 9anime|Watch .*? Sub/Dub online Free on Aniwatch\.to)$") {  ; time stamp can't be in url and ^a doesn't cover time stamp
      return 3
    } else if (Title ~= "(-免费在线观看-爱壹帆|_[^_]+ - 喜马拉雅|_高清在线观看 – NO视频)$") {  ; time stamp can't be in url and ^a doesn't cover time stamp
      return 3
    }
  }

  Highlight(CollName:="", PlainText:="", Url:="") {
    this.ActivateBrowser()
    CollName := CollName ? CollName : this.Vim.SM.GetCollName()
    Sent := False
    if (RegexMatch(PlainText, "(?<!\s)(?<!\d)\d+\.", v)) {
      Url := Url ? Url : this.GetParsedUrl()
      if (IfContains(Url, "fr.wikipedia.org")) {
        Sent := True
        send % "+{left " . StrLen(v) . "}"
      }
    }
    if (!Sent && RegexMatch(PlainText, "(\[(\d+|note \d+)\])+。?$|\[\d+\]: \d+。?$|(?<=\.)\d+$", v)) {
      Url := Url ? Url : this.GetParsedUrl()
      if (IfContains(Url, "wikipedia.org"))
        send % "+{left " . StrLen(v) . "}"
    }
    ; ControlSend doesn't work reliably because browser can't highlight in background
    if (CollName = "zen") {
      send ^+h
    } else {
      send !+h
    }
    sleep 700  ; time for visual feedback
  }

  ClickBtn() {
    this.ActivateBrowser()
    this.Url := this.Url ? this.Url : this.GetParsedUrl()
    if (IfContains(this.Url, "youtube.com/watch")) {
      global guiaBrowser := guiaBrowser ? guiaBrowser : new UIA_Browser("ahk_exe " . WinGet("ProcessName", "A"))
      if (!btn := guiaBrowser.FindFirstBy("ControlType=Button AND Name='...more' AND AutomationId='expand'"))
        btn := guiaBrowser.FindFirstBy("ControlType=Text AND Name='...more'")
      btn.FindByPath("P2").Click()  ; click the description box, so the webpage doesn't scroll down
    }
  }

  ActivateBrowser() {
    if (!WinActive("ahk_group Browser"))
      WinActivate, ahk_group Browser
  }
}

ClickBrowserBtn:
  Vim.Browser.ClickBtn()
  ClickBrowserBtnFinished := true
return
