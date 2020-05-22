Function Get-LastLogon
{
<#

.SYNOPSIS

This function will list the last user logged on or logged in.

.DESCRIPTION

This function will list the last user logged on or logged in.  It will detect if the user is currently logged on
via WMI or the Registry, depending on what version of Windows it runs against.  There is some "guess" work
to determine what Domain the user truely belongs to if run against Vista NON SP1 and below, since the function
is using the profile name initially to detect the user name.  It then compares the profile name and the Security
Entries (ACE-SDDL) to see if they are equal to determine Domain and if the profile is loaded via the Registry.

.PARAMETER ComputerName

A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

.EXAMPLE

$Servers = Get-Content "C:\ServerList.txt"
Get-LastLogon -ComputerName $Servers

This example will return the last logon information from all the servers in the C:\ServerList.txt file.

Computer     User                 Time                   CurrentlyLoggedOn
--------     ----                 ----                   -----------------
Server1      DOMAIN\USER1         2/7/2012 8:45:05 AM                 True
Server2      DOMAIN\USER2         2/2/2012 4:40:16 PM                False

.LINK
http://msdn.microsoft.com/en-us/library/windows/desktop/ee886409(v=vs.85).aspx
http://msdn.microsoft.com/en-us/library/system.security.principal.securityidentifier.aspx

.NOTES
Author:  Brian C. Wilhite
Email:   bwilhite1@carolina.rr.com
Date:    01/27/2012
#>

[CmdletBinding()]
param(
  [Parameter(Position=0,ValueFromPipeline=$true)]
  [Alias("CN","Computer")]
  [String[]]$ComputerName="$env:COMPUTERNAME"
  )

Begin
  {
    #Adjusting ErrorActionPreference to stop on all errors
    $TempErrAct = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
  }#End Begin Script Block

Process
  {
    Foreach ($Computer in $ComputerName)
      {
        $Computer = $Computer.ToUpper().Trim()
        Try
          {
            $Win32OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
            $Build = $Win32OS.BuildNumber
            If ($Build -ge 6001)
              {
                $Win32User = Get-WmiObject -Class Win32_UserProfile -ComputerName $Computer
                #Filtering out the System, NetworkService and LocalService SIDS with RegEx
                $Win32User = $Win32User | Where-Object {($_.SID -notmatch "^S-1-5-\d[18|19|20]$")}
                $Win32User = $Win32User | Sort-Object -Property LastUseTime -Descending
                $LastUser = $Win32User | Select-Object -First 1
                $Loaded = $LastUser.Loaded
                $Time = ([WMI]'').ConvertToDateTime($LastUser.LastUseTime)
                
                #Convert SID to Account for friendly display
                $UserSID = New-Object System.Security.Principal.SecurityIdentifier($LastUser.SID)
                $User = $UserSID.Translate([System.Security.Principal.NTAccount])
                
                #Creating the PSObject UserProf
                $UserProf = New-Object PSObject -Property @{
                Computer=$Computer
                User=$User
                Time=$Time
                CurrentlyLoggedOn=$Loaded
                }
                
                #Formatting Object Output
                $UserProf = $UserProf | Select-Object Computer, User, Time, CurrentlyLoggedOn
                $UserProf
              }#End If ($Build -ge 6001)
            If ($Build -le 6000)
              {
                If ($Build -eq 2195)
                  {
                    $SysDrv = $Win32OS.SystemDirectory.ToCharArray()[0] + ":"
                  }#End If ($Build -eq 2195)
                Else
                  {
                    $SysDrv = $Win32OS.SystemDrive
                  }#End Else
                $SysDrv = $SysDrv.Replace(":","$")
                $ProfDrv = "\\" + $Computer + "\" + $SysDrv
                $ProfLoc = Join-Path -Path $ProfDrv -ChildPath "Documents and Settings"
                $Profiles = Get-ChildItem -Path $ProfLoc
                $LastProf = $Profiles | ForEach-Object -Process {$_.GetFiles("ntuser.dat.LOG")}
                $LastProf = $LastProf | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
                $UserName = $LastProf.DirectoryName.Replace("$ProfLoc","").Trim("\").ToUpper()
                $Time = $LastProf.LastAccessTime
                
                #Getting the SID of the user from the file ACE to compare
                $Sddl = $LastProf.GetAccessControl().Sddl
                $Sddl = $Sddl.split("(") | Select-String -Pattern "[0-9]\)$" | Select-Object -First 1
                #Formatting SID, assuming the 6th entry will be the users SID.
                $Sddl = $Sddl.ToString().Split(";")[5].Trim(")")
                
                #Convert Account to SID to detect if profile is loaded via the remote registry
                $TranSID = New-Object System.Security.Principal.NTAccount($UserName)
                $UserSID = $TranSID.Translate([System.Security.Principal.SecurityIdentifier])
                If ($Sddl -eq $UserSID)
                  {
                    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"Users",$Computer)
                    $Loaded = $Reg.GetSubKeyNames() -contains $UserSID.Value
                    #Convert SID to Account for friendly display
                    $UserSID = New-Object System.Security.Principal.SecurityIdentifier($UserSID)
                    $User = $UserSID.Translate([System.Security.Principal.NTAccount])
                  }#End If ($Sddl -eq $UserSID)
                Else
                  {
                    $User = $UserName
                    $Loaded = "Unknown"
                  }#End Else
                
                #Creating the PSObject UserProf
                $UserProf = New-Object PSObject -Property @{
                Computer=$Computer
                User=$User
                Time=$Time
                CurrentlyLoggedOn=$Loaded
                }
                
                #Formatting Object Output
                $UserProf = $UserProf | Select-Object Computer, User, Time, CurrentlyLoggedOn
                $UserProf
              }#End If ($Build -le 6000)
          }#End Try
        Catch
          {
            Write-Warning "$Computer threw an exception"
            $Error[0].Exception
          }#End Catch
      }#End Foreach ($Computer in $ComputerName)
  }#End Process
  
End
  {
    #Resetting ErrorActionPref
    $ErrorActionPreference = $TempErrAct
  }#End End

}# End Function Get-LastLogon