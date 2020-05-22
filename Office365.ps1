#Credentials
$User = "fabian.campo@campohenriquezlab.onmicrosoft.com"
$Pass = ConvertTo-SecureString "M@qu1n@D3G43rr@" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
#Import the Modules
Import-Module MSOnline
#Import-Module skypeOnlineConnector
import-module microsoft.online.sharepoint.powershell
#Connect Office365 Tenant Licensing portal
Connect-msolservice -Credential $Cred
#Connect Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session
#Connect SkypeOnline
#$SessionS4B = New-CsOnlinesession -Credential $Cred
#Import-PSSession $SessionS4B
#Connect Sharepoint Online
[string]$tenant = get-msoldomain | where {$_.name -like "*.onmicrosoft.com" -and -not($_.name -like "*mail.onmicrosoft.com")} | select name
$tenant
$tenant3 = $tenant -split("=")
[string]$tenant4 = $tenant3[1]
$tenant4
$tenant5 = $tenant4 -split(".on")
[string]$tenant6 = $tenant5[0]
$url = "https://" + $tenant6 + "-admin.sharepoint.com"
Connect-SPOService -Url $url -credential $Cred