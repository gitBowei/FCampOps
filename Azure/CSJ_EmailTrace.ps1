$pw = convertto-securestring -AsPlainText -Force -String “Csj-20#20$”
$SessionOptions = New-PSSessionOption -IdleTimeout 600000 -NoCompression:$True
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "msgtracereporting@etbcsj.onmicrosoft.com",$pw
Write-Progress -activity "Conectamos a Exchange Online"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -SessionOption $sessionOptions -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential ($cred) -Authentication Basic -AllowRedirection
Write-Progress -activity "Importamos el metodo"
Import-PSSession $Session

Write-output "Son las: " (Get-date)
$objusers=get-mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
##$objusers=get-msoluser -enabledfilter EnabledOnly -MaxResults 20000 |Select UserPrincipalName
##$objusers
Write-output "termine de listarlos usuarios a las: " (Get-date)
Write-Output ($objusers).count
$objusers | Export-CSV -path "c:\logs\Buzones.csv" -Encoding UTF8 -Append -NoTypeInformation

$mensajes = Get-MessageTrace -StartDate "2020-04-30T00:00:00Z" -EndDate "2020-04-30T01:59:59Z" -PageSize 5000 | Export-CSV -path "c:\logs\30Abr2020.csv" -Append -NoTypeInformation
($mensajes).count
