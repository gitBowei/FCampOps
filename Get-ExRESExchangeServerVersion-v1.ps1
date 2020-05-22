#Get-ExchangeServerPlus.ps1
#v1.3, 07/11/2011
#Written By Paul Flaherty, blogs.flaphead.com
#Modified by Jeff Guillet, www.expta.com
#modified by Gregorio Parra, blogs.technet.com


<#

 Exchange Server 2013 RTM	 15.0.516.32
 Exchange Server 2013 Cumulative Update 1 (CU1)	 620.29
 Exchange Server 2013 Cumulative Update 2 (CU2)	 712.24
 Exchange Server 2013 Cumulative Update 3 (CU3)	 775.38
 Exchange Server 2013 Service Pack 1 (SP1 aka CU4)	 847.32
 Exchange Server 2013 Cumulative Update 5 (CU5)	 913.22
 Exchange Server 2013 Cumulative Update 6 (CU6)	 995.29

 #>
$versiones = @{

  "516.32"="Exchange Server 2013 RTM";
  "620.29"="Exchange Server 2013 Cumulative Update 1 (CU1)";
  "712.24"="Exchange Server 2013 Cumulative Update 2 (CU2)";
  "775.38"="Exchange Server 2013 Cumulative Update 3 (CU3)";
  "847.32"="Exchange Server 2013 Service Pack 1 (SP1 aka CU4)";
  "913.22"="Exchange Server 2013 Cumulative Update 5 (CU5)"	;
  "995.29"="Exchange Server 2013 Cumulative Update 6 (CU6)"
}

$b = New-Object 'object[,]' 8,2
$b[0,0] = "516.32"
$b[0,1] = "Exchange Server 2013 RTM"
$b[2,0] = "620.29"
$b[2,1] = "Exchange Server 2013 Cumulative Update 1 (CU1)"
$b[3,0] = "712.24"
$b[3,1] = "Exchange Server 2013 Cumulative Update 2 (CU2)"
$b[4,0] = "775.38"
$b[4,1] = "Exchange Server 2013 Cumulative Update 3 (CU3)"
$b[5,0] = "847.32"
$b[5,1] = "Exchange Server 2013 Service Pack 1 (SP1 aka CU4)"
$b[6,0] = "913.22"
$b[6,1] = "Exchange Server 2013 Cumulative Update 5 (CU5)"
$b[7,0] = "995.29"
$b[7,1] = "Exchange Server 2013 Cumulative Update 6 (CU6)"


#Get a list of Exchange servers in the Org excluding Edge servers
$MsxServers = Get-ExchangeServer | where {$_.ServerRole -ne "Edge" } | where {$_.ServerRole -ne "ProvisionedServer" } | sort Name

#Loop through each Exchange server that is found
ForEach ($MsxServer in $MsxServers)
{

    #Get Exchange server version
    $MsxVersion = $MsxServer.ExchangeVersion

	#Create "header" string for output
	# Servername [Role] [Edition] Version Number
    $majorver = $MsxServer.AdminDisplayVersion.Major
    $txt1 = $MsxServer.Name + " [" + $MsxServer.ServerRole + "] [" + $MsxServer.Edition + "] [" + $MsxServer.AdminDisplayVersion + "] [Version:" + $majorver + "]"
	write-host $txt1 

	#Connect to the Server's remote registry and enumerate all subkeys listed under "Patches"
	$Srv = $MsxServer.Name
    $key = ""

    #define the registry key, depending on Exchange Version 2007 or 2010
    if ($majorver -eq "8") # Exchange 2007
    {
	   $key = "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\461C2B4266EDEF444B864AD6D9E5B613\Patches\"
    }
    if ($majorver -eq "14") # Exchange 2010
    {
	   $key = "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\AE1D439464EB1B8488741FFA028E291C\Patches\"
    }
    if ($majorver -eq "15") # Exchange 2013
    {
        $key = "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\AE1D439464EB1B8488741FFA028E291C\Patches\"
        for ($i=0; $i -le 7; $i++){
            if ( $txt1 -match $b[$i,0]   ){
                write-host  $b[$i,1] -ForegroundColor DarkGreen
            }
        }
    }
	$type = [Microsoft.Win32.RegistryHive]::LocalMachine
	$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $Srv)
	$regKey = $regKey.OpenSubKey($key)

	#Loop each of the subkeys (Patches) and gather the Installed date and Displayname of the Exchange 2007 patch
	$ErrorActionPreference = "SilentlyContinue"
	ForEach($sub in $regKey.GetSubKeyNames())
	{
		Write-Host "- " -nonewline -ForegroundColor DarkRed
		$SUBkey = $key + $Sub
		$SUBregKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $Srv)
		$SUBregKey = $SUBregKey.OpenSubKey($SUBkey)
		ForEach($SubX in $SUBRegkey.GetValueNames())
		{
			# Display Installed date and Displayname of the Exchange 2007 patch
			IF ($Subx -eq "Installed")   {
				$d = $SUBRegkey.GetValue($SubX)
				$d = $d.substring(4,2) + "/" + $d.substring(6,2) + "/" + $d.substring(0,4)
				write-Host $d -NoNewLine
			}
			IF ($Subx -eq "DisplayName") {write-Host ": "$SUBRegkey.GetValue($SubX) -ForegroundColor DarkGreen}
		}
	}
	write-host ""
}