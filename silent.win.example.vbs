Set WshShell = CreateObject("WScript.Shell" )
WshShell.Run chr(34) & "D:\PathToBatchFile\e.win.bat" & Chr(34), 0
Set WshShell = Nothing