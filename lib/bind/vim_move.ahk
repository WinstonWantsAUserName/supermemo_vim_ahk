﻿#Requires AutoHotkey v1.1.1+  ; so that the editor would recognise this script as AHK V1
; Inner mode
#if (Vim.IsVimGroup()
  && !Vim.State.StrIsInCurrentVimMode("Inner,Outer")
  && (Vim.State.StrIsInCurrentVimMode("Vim_ydc,SMVim_,Vim_g")
   || Vim.State.IsCurrentVimMode("Vim_VisualChar,Vim_VisualFirst")))
i::Vim.State.SetInner()
a::Vim.State.SetOuter()

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Inner"))
w::
s::
p::
(::
)::
{::
}::
[::
]::
<::
>::
'::Vim.Move.Inner(A_ThisLabel)
t::Vim.Move.Inner("<")
b::Vim.Move.Inner("(")
+b::Vim.Move.Inner("{")
"::Vim.Move.Inner("""")

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Outer"))
w::
s::
p::
(::
)::
{::
}::
[::
]::
<::
>::
'::Vim.Move.Outer(A_ThisLabel)
t::Vim.Move.Outer("<")
b::Vim.Move.Outer("(")
+b::Vim.Move.Outer("{")
"::Vim.Move.Outer("""")

; gg
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.g)
g::Vim.State.SetMode("", 1, -1)
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && Vim.State.g)
g::Vim.Move.Move("g")
_::Vim.Move.Move("$")

#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && GetKeyState("j", "P") && SM.IsEditingText())
k::Send {Up}{Esc}
#if (Vim.IsVimGroup() && Vim.State.IsCurrentVimMode("Vim_Normal") && GetKeyState("k", "P") && SM.IsEditingText())
j::Send {Down}{Esc}

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_"))
; 1 character
BS::
h::Vim.Move.Repeat("h")
j::Vim.Move.Repeat("j")
k::Vim.Move.Repeat("k")
Space::
l::Vim.Move.Repeat("l")
; Home/End
0::Vim.Move.Move("0")
$::Vim.Move.Move("$")
^::Vim.Move.Move("^")
+::Vim.Move.Repeat("+")
-::Vim.Move.Repeat("-")
; Words
w::Vim.Move.Repeat("w")
e::Vim.Move.Move("e")
b::Vim.Move.Repeat("b")
; Page Up/Down
^u::Vim.Move.Repeat("^u")
^d::Vim.Move.Repeat("^d")
^b::Vim.Move.Repeat("^b")
^f::Vim.Move.Repeat("^f")
; G
+g::Vim.Move.Move("+g")
; Paragraph up/down
{::Vim.Move.Repeat("{")
}::Vim.Move.Repeat("}")
; Other motions
x::Vim.Move.Repeat("x")
+x::Vim.Move.Repeat("+x")
; Sentence
(::
)::Vim.Move.Move(A_ThisLabel)

'::Vim.State.SetMode(,, -1,,, -1, 1)  ; leader key

#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_Visual"))
Enter::Vim.Move.Repeat("j")

; Search
#if (Vim.IsVimGroup() && Vim.State.StrIsInCurrentVimMode("Vim_") && !Vim.State.StrIsInCurrentVimMode("Vim_Normal") && !Vim.State.fts)
/::Vim.Move.Move("/")
?::Vim.Move.Move("?")
