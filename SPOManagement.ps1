Install-Module AzureAD
Install-Module MSonline
Get-Command -Module AzureAD
Get-AzureADDomain
Get-AzureADTenantDetail
Get-AzureADUser
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "Pa55w.rd1234"
New-AzureADUser -DisplayName "Stephanie Campo" -PasswordProfile $PasswordProfile -UserPrincipalName "scampo@colmct.onmicrosoft.com" -AccountEnabled $true -MailNickName "Stefy"
Get-AzureADUser | ft userprincipalname, department
Get-AzureADUser | Set-AzureADUser -Department "O365Support"
get-installedmodule
#Install SPO Posh module from web,
Connect-SPOService -Url https://colmct-admin.sharepoint.com -credential fcampo@colmct.onmicrosoft.com
Get-SPOSite -IncludePersonalSite $true
get-help *SPO* | where modulename -eq microsoft.online.sharepoint.powershell
new-sposite -url https://colmct.sharepoint.com/sites/AzureTrainers -Owner fcampo@colmct.onmicrosoft.com -Template STS#0 -ResourceQuota 100 -Storagequota 500
$sites = Import-Csv ~\documents\bulkcreatesites.csv
$root = "https://colmct.sharepoint.com/sites/"
foreach($site in $sites) {
    New-SPOSite -url ($root+$site.url) -Owner $site.owner -StorageQuota $site.storage -Title $site.title -Template $site.template -NoWait
    Write-Host "Created site at" ($root+$site.url)
}
Get-SPOSite -Detailed | ft Url, CompatibilityLevel
Get-spotenant
Get-SPOSite | Select url, storageusagecurrent, storagequota | ft -wrap -autosize
Get-SPOSite | Select url, storageusagecurrent, storagequota | where {($_.storageusagecurrent / $_.storagequota) -gt 0.001}
Get-SPOSite | Select url, LastContentModifiedDate | ft -wrap -autosize
Get-SPOSite -includepersonalsite $true | Select url, template | where {$_.template -eq "SPSPERS#10"}
Set-SPOSite https://colmct.sharepoint.com/sites/marketing -lockstate NoAccess
Set-SPOTenant -NoAccessRedirectURL https://colmct.sharepoint.com/portals/Community
Set-SPOSite https://colmct.sharepoint.com/sites/marketing -lockstate Unlock
Remove-SPOSite -Identity https://colmct.sharepoint.com/sites/products
Get-spodeletedsite |fl
Restore-SPODeletedSite -Identity https://colmct.sharepoint.com/sites/products -nowait
