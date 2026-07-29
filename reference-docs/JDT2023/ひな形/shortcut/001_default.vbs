
Dim oShell
Set oShell = WScript.CreateObject ("WSCript.shell")


ans = MsgBox("初期設定を実行する場合は「はい」を"& vbCr & "初期設定を実行しない場合は「いいえ」" & vbCr & "を選択して下さい。", vbYesNo,"初期設定")
If ans = vbYes Then oShell.run "c:\jsa_admin_work\001_default.exe",0
If ans = vbNo  Then MsgBox "「キャンセルします」"

