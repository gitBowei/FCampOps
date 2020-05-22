$connectTestResult = Test-NetConnection -ComputerName sto8899.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"sto8899.file.core.windows.net`" /user:`"Azure\sto8899`" /pass:`"j7Y5NkKkttzglRCfP2hkwpMAUUv0yjPO5JFV8uA9ELTrDNsSTmijTmHLzGP3nRN7IZEcQpF5fNhSWU5S5ePjuQ==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\sto8899.file.core.windows.net\starwarspdf" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
