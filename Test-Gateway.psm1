function Test-Gateway {
    param($Computer = $null,
     $Count = "1")
    If ($Computer -eq $null)
    {Test-Connection -Destination (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Count $Count}
     else
     {$Route=Invoke-Command -ComputerName $Computer {Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop}; Test-Connection -Source $Computer -Destination $Route -Count $Count}
     }