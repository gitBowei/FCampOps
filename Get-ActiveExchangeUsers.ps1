<# 
 
.SYNOPSIS 
 
Created by: https://ingogegenwarth.wordpress.com/ 
Version:    42 ("What do you get if you multiply six by nine?") 
Changed:    29.06.2016 
 
.DESCRIPTION 
 
The script is enumerating all Exchange 2010 CAS and Exchange 2013/2016 servers in the current or given AD site and queries specific performance counters 
 
.LINK 
 
http://mikepfeiffer.net/2011/04/determine-the-number-of-active-users-on-exchange-2010-client-access-servers-with-powershell/ 
https://technet.microsoft.com/library/hh849685.aspx 
https://www.granikos.eu/en/justcantgetenough/PostId/197/inline-css-with-convertto-html 
https://ingogegenwarth.wordpress.com/2016/05/09/get-activeexchangeusers-2-0/ 
 
.PARAMETER ADSite 
 
here you can define in which ADSite is searched for Exchange server. If omitted current AD site will be used. 
 
.PARAMETER Summary 
 
if used the script will sum up the active user count across all servers per protocol 
 
.PARAMETER HTTPProxyAVGLatency 
 
the script will collect for each protocol the performance counter "\MSExchange HttpProxy(protocoll)\Average ClientAccess Server Processing Latency" 
 
.PARAMETER HTTPProxyOutstandingRequests 
 
the script will collect for each protocol the performance counter "\MSExchange HttpProxy(protocoll)\Outstanding Proxy Requests" 
 
.PARAMETER HTTPProxyRequestsPerSec 
 
the script will collect for each protocol the performance counter "\MSExchange HttpProxy(protocoll)\\Proxy Requests/Sec" 
 
.PARAMETER E2EAVGLatency 
 
the script will collect for main protocols counters like "\MSExchangeIS Client Type(*)\RPC Average Latency",\MSExchange RpcClientAccess\RPC Averaged Latency","\MSExchange MapiHttp Emsmdb\Averaged Latency" 
 
.PARAMETER MaxSamples 
 
as the script uses the CmdLet Get-Counter you can define the number of MaxSamples. Default is 1 
 
.PARAMETER SendMail 
 
switch to send an e-mail with a CSV attached 
 
.PARAMETER From 
 
define the sender address 
 
.PARAMETER Recipients 
 
define the recipients 
 
.PARAMETER SmtpServer 
 
which SmtpServer to use 
 
.EXAMPLE 
 
Get users from current AD site 
.\Get-ActiveExchangeUsers.ps1 
 
Get users from given AD site 
.\Get-ActiveExchangeUsers.ps1 -ADSite HQ-Site 
 
Get summary 
 
.\Get-ActiveExchangeUsers.ps1 -Summary 
 
Get number of outstanding proxy requests for 60 samples 
 
.\Get-ActiveExchangeUsers.ps1 -HTTPProxyOutstandingRequests -MaxSamples 60 
 
Get number of average processing time of proxy requests 
 
.\Get-ActiveExchangeUsers.ps1 -HTTPProxyAVGLatency 
 
Get number of proxy requests per second 
 
.\Get-ActiveExchangeUsers.ps1 -HTTPProxyRequestsPerSec 
 
Get backend related AVG latency for main components 
 
.\Get-ActiveExchangeUsers.ps1 -E2EAVGLatency 
 
Get time in GC for main components 
 
.\Get-ActiveExchangeUsers.ps1 -TimeInGC 
 
.NOTES 
 
You need to run this script in the same AD site where the servers are for performance reasons. 
 
#> 
[CmdletBinding(DefaultParameterSetName = "ALL")] 
param( 
    [parameter( Mandatory=$false, Position=0)] 
    [string]$ADSite="$(([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()).GetDirectoryEntry().Name)", 
     
    [parameter( Mandatory=$false, Position=1, ParameterSetName="Summary")] 
    [switch]$Summary, 
     
    [parameter( Mandatory=$false, Position=2, ParameterSetName="HTTPProxyAVGLatency")] 
    [switch]$HTTPProxyAVGLatency, 
     
    [parameter( Mandatory=$false, Position=3, ParameterSetName="HTTPProxyOutstandingRequests")] 
    [switch]$HTTPProxyOutstandingRequests, 
     
    [parameter( Mandatory=$false, Position=4, ParameterSetName="HTTPProxyRequestsPerSec")] 
    [switch]$HTTPProxyRequestsPerSec, 
     
    [parameter( Mandatory=$false, Position=5, ParameterSetName="E2EAVGLatency")] 
    [switch]$E2EAVGLatency, 
 
    [parameter( Mandatory=$false, Position=6, ParameterSetName="TimeInGC")] 
    [switch]$TimeInGC, 
 
    [parameter( Mandatory=$false, Position=7)] 
    [array]$SpecifiedServers, 
 
    [parameter( Mandatory=$false, Position=8)] 
    [int]$MaxSamples = 1, 
 
    [parameter( Mandatory=$false, Position=9)] 
    [switch]$SendMail, 
 
    [parameter( Mandatory=$false, Position=10)] 
    [String]$From, 
 
    [parameter( Mandatory=$false, Position=11)] 
    [String[]]$Recipients, 
 
    [parameter( Mandatory=$false, Position=12)] 
    [string]$SmtpServer 
 
)