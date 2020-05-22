$ODJCommand = '"djoin.exe /requestodj /loadfile C:\Client.txt /windowspath %systemroot% /localos"'

Start-Process "cmd.exe" -ArgumentList "/K $ODJCommand"

shutdown.exe /t 0 /r /f