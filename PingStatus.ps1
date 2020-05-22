###------------------------------###  
### Author : Biswajit Biswas-----###    
###MCC, MCSA,MCTS, CCNA, SME,ITIL###  
###Email<bshwjt@gmail.com>-------###  
###------------------------------###  
###/////////..........\\\\\\\\\\\###  
###///////////.....\\\\\\\\\\\\\\###
###Required PS Version 3 or Above###  
Function UPTimeReport {
$Prop = [ordered]@{}
$ComputerName = Get-content "C:\Computers.txt" -ReadCount 0
$ErrorActionPreference = "Stop"
foreach ($computer in $ComputerName) 
  { 
  
Try {

$GWMIC = Get-EventLog -log System -cn $computer
$Prop.Computername = GWMI win32_operatingsystem -cn $computer | Select-object -ExpandProperty CSName 
$Prop.LastRebootTime12 =  $GWMIC | ? EventID -EQ 12 | Select-Object -ExpandProperty TimeGenerated -First 1 
$Prop.RebootDoneBy12 = $GWMIC | ? EventID -EQ 12 | Select-Object -ExpandProperty username -First 1
$Prop.Reason12 =  $GWMIC | ? EventID -EQ 12 | Select-Object -ExpandProperty Message -First 1
$Prop.LastRebootTime1074 =  $GWMIC | ? EventID -EQ 1074 | Select-Object -ExpandProperty TimeGenerated -First 1
$Prop.RebootDoneBy1074 = $GWMIC | ? EventID -EQ 1074 | Select-Object -ExpandProperty username -First 1
$Prop.Reason1074=  $GWMIC | ? EventID -EQ 1074 | Select-Object -ExpandProperty Message -First 1

$StartDate = $GWMIC | ? EventID -EQ 12 | Select-Object -ExpandProperty TimeGenerated -First 1
$EndDate = $GWMIC | ? EventID -EQ 1074 | Select-Object -ExpandProperty TimeGenerated -First 1
$Prop.TimeDiff = NEW-TIMESPAN –Start $EndDate –End $StartDate

New-Object PSObject -property $Prop 
  }  

  Catch
  {
  
  Add-Content "$computer is not reachable" -path $env:USERPROFILE\Desktop\UnreachableHosts.txt
  }
 }
}
#HTML Color Code
#http://technet.microsoft.com/en-us/librProp/ff730936.aspx
$a = "<style>"
$a = $a + "BODY{background-color:#DAA520;font-family:verdana;font-size:10pt;}"
$a = $a + "TABLE{border-width: 2px;border-style: solid;border-color:#000000;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: #000000;background-color:#7FFF00;}" 
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: #000000;background-color:#FFD700;}"
$a = $a + "</style>"
UPTimeReport | ConvertTo-HTML -head $a -body "<H2> UPTime Report</H2>" | 
Out-File $env:USERPROFILE\Desktop\uptime.htm #HTML Output
Invoke-Item $env:USERPROFILE\Desktop\uptime.htm