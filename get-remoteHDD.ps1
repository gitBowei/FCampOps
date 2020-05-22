#Use Powershell to Gather Disk/Partition/Mount Point Information

$cred = Get-Credential
Get-RemoteDiskInformation -ComputerName Test1 -Credential $cred