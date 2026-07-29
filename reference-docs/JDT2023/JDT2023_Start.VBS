Option Explicit

Dim objFso
Dim objWord
Dim macroFile
Dim ws


Set objFso = CreateObject("Scripting.FileSystemObject")
macroFile = objFso.getParentFolderName(WScript.ScriptFullName)
macroFile = macroFile & "\JIS_Control.dotm"

REM Set objWord = CreateObject("Word.Application")
REM objWord.Visible = True
REM objWord.AddIns.Add macroFile, True

Set ws = CreateObject("WScript.Shell")
ws.Run "cmd.exe" & " /c START Winword.exe /n /m /l" & CHR(34) & macroFile & CHR(34)

