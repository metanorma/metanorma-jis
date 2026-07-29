Dim objShell
Set objShell = CreateObject("WScript.Shell")  
Dim objShortCut
Dim strDesktop
Dim strFileName
Dim strTargetPath

Dim objFso
Dim cstrFPath
Dim iconFilePath


Set objFso = CreateObject("Scripting.FileSystemObject")
cstrFPath = objFso.getParentFolderName(WScript.ScriptFullName)
iconFilePath = cstrFPath & "\JDT2023.ico"


Rem デスクトップを指定
strDesktop = objShell.SpecialFolders("Desktop")

Rem ===============================================================================================
Rem VBSファイルショートカット
Rem ===============================================================================================
Rem ショートカット名の指定
strFileName =strDesktop + "\JDT2023_VBS.lnk"
Rem ショートカット作成
Set objShortCut = objShell.CreateShortcut(strFileName)
Rem 実行ファイルの指定
strTargetPath = cstrFPath & "\JDT2023_Start.vbs"
objShortCut.TargetPath = strTargetPath
Rem ショートカットアイコンを設定
Rem objShortCut.IconLocation = "C:\JDT\JDT2023\JDT2023.ico,0"
objShortCut.IconLocation = iconFilePath & ",0"
Rem 作業フォルダ
objShortCut.WorkingDirectory = cstrFPath
objShortCut.Save

Set objShortCut = Nothing

Rem ===============================================================================================
Rem BATファイルショートカット
Rem ===============================================================================================
Rem ショートカット名の指定
strFileName =strDesktop + "\JDT2023_BAT.lnk"
Rem ショートカット作成
Set objShortCut = objShell.CreateShortcut(strFileName)
Rem 実行ファイルの指定
strTargetPath = cstrFPath & "\JDT2023_Start.bat"
objShortCut.TargetPath = strTargetPath
Rem ショートカットアイコンを設定
Rem objShortCut.IconLocation = "C:\JDT\JDT2023\JDT2023.ico,0"
objShortCut.IconLocation = iconFilePath & ",0"
Rem 作業フォルダ
objShortCut.WorkingDirectory = cstrFPath
objShortCut.Save

Set objShortCut = Nothing
Set objShell = Nothing
