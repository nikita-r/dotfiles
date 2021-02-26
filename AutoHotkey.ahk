;·AutoHotkey.ahk

#KeyHistory 0

OnError("DoSomething")
DoSomething(exception) {
    MsgBox % "Error at Line " exception.Line
           . "`n" "* " RTrim(exception.Extra, " `r`n")
           . "`n" exception.Message
    return true
}

SetTitleMatchMode RegEx
SendMode InputThenPlay


;SetWorkingDir, D:\rk
;#c::Run pind.cmd
;+#c::Run %ComSpec%, %SystemDrive%\Windows\System32
#c::Run %ComSpec%, %UserProfile%
+#c::Run, *RunAs %ComSpec%

#n::Run Notepad, %UserProfile%\Documents
+#n::Run, *RunAs Notepad

F1:: ; nope
return

; Disable keyboard shortcuts for Undo/Redo in Windows Explorer
#IfWinActive ahk_exe explorer.exe
^z::
^y::
SoundPlay,*-1
Send,{esc}
MsgBox Windows Explorer: Ctrl+Z and Ctrl+Y are disabled
return
#If

; these key combinations are often set up to effect display rotation
^!Up::return
^!Down::return
^!Left::return
^!Right::return

; otherwise, these two duplicate Super+↓/↑
^#Up::return
^#Down::return

;Browser_Back::send,!{left}
;Browser_Forward::send,!{right}
;+Browser_Back::send,+!{left}
;+Browser_Forward::send,+!{right}

#IfWinActive ahk_exe explorer.exe
^WheelUp::return
^WheelDown::return
#IfWinActive


; ~\Desktop
#If WinActive("ahk_class Progman")
#If

; prevent vim from crushing my spirit
#If WinActive("ahk_class ConsoleWindowClass") and WinActive("^vim «.*»$")
^+!Up::return
^+!Down::return
^+!Left::return
^+!Right::return
^Up::return
^Down::return
^Left::return
^Right::return
^+Up::return
^+Down::return
^+Left::return
^+Right::return

; Python REPL
#If WinActive("ahk_class ConsoleWindowClass") and WinActive("^Python [A-Z]$")
Tab::Send {Space 4}
+Tab::Send   {bs 4}
^Tab::Send {Tab}

; Ruby REPL
#If WinActive("ahk_class ConsoleWindowClass") and WinActive(" - ruby$")
Tab::Send {Space 2}
+Tab::Send   {bs 2}
^Tab::Send {Tab}

#If
; please do not Cut
+Del::Send {Del}


; en dash
!-::send {asc 0150}

; em dash
!+-::send {asc 0151}

!=::send ≈

; ±
!+=::send {asc 0177}

;·middle·dot
!.::send {asc 0183}

; • bullet
!+.::send {asc 0149}


; Shortcuts to delete a word in an Edit control
;
#If ActiveControlIsOfClass("Edit")
^BS::Send ^+{Left}{Del}
^Del::Send ^+{Right}{Del}
#If

ActiveControlIsOfClass(Class) {
    ControlGetFocus, FocusedControl, A
    ControlGet, FocusedControlHwnd, Hwnd,, %FocusedControl%, A
    WinGetClass, FocusedControlClass, ahk_id %FocusedControlHwnd%
    return (FocusedControlClass=Class)
}


