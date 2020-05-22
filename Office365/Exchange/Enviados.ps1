#pide los datos de las variables de usuario y contraseña para iniciar sesion en powersehll y el nombre del archivo a cargar
param (
[string]$MessageId,
[string]$MessageSubject,
[string]$Recipients,
[string]$Reference,
[string]$ResultSize,
[string]$Sender,
[string]$Source,
[datetime]$Start,
[datetime]$End,
[string]$HideHealthMessages
#[string]$Username,
#[SecureString]$Password
)

$Username = "fabian.campo@campohenriquez.com"
$Password = "St3ph4n13."
$Cred = [System.Management.Automation.PSCredential]::new($Username, ($Password | ConvertTo-SecureString -asPlainText -Force))

# ENCODING (force script output to UTF8 encoding)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# FUNCTION TO CONVERT CP866
function cp866-to-utf8 ([string]$str){
$byte = [System.Text.Encoding]::GetEncoding("cp866").getbytes($str)
$utf8 = [System.Text.Encoding]::UTF8.GetString($byte)
return $utf8
}

# FUNCTION TO ADD QUOTES
function add-quotes ([string]$str){
$strwithquotes = "'"+$str+"'"
return $strwithquotes
}

# PASS SCRIPT PARAMETERS WITH $PSBoundParameters
$ScriptParams =[ordered]@{}
$PSBoundParameters.Keys | foreach { 
switch ($_) {
{$_ -eq "HideHealthMessages"}{return} # exclude unnecessary pararmeters
{$_ -eq "Powershellpath"}{return} # exclude unnecessary pararmeters
{$_ -eq "Username"}{return} # exclude unnecessary pararmeters
{$_ -eq "Password"}{return} # exclude unnecessary pararmeters       
{$_ -eq "Start"} {$ScriptParams.Add($_,(add-quotes($PSBoundParameters.item($_))));return} #add quotes to date string
{$_ -eq "End"}   {$ScriptParams.Add($_,(add-quotes($PSBoundParameters.item($_))));return} #add quotes to date string
{$_ -eq "MessageSubject"} {$ScriptParams.Add($_,(add-quotes(cp866-to-utf8($PSBoundParameters.item($_)))));return} #add quotes to string and convert to utf8
default {$ScriptParams.Add($_,$PSBoundParameters.item($_))}
}
}

$ScriptParams.Add('WarningAction','silentlyContinue') #supress warnings

Function Main { 

    Write-Progress -activity "ENTRANDO AL METODO PRINCIPAL"
    Write-Output "CERRANDO SESION ACTIVA"
    Get-PSSession | Remove-PSSession
    Write-Progress -activity "----------------------------------------------------------------------"
    ConnectTo-ExchangeOnline -Username $Username -Password $Password    
    ## Out-File -FilePath $OutputFile -InputObject "MessageTraceId,MessageID,SenderAddress,RecipientAddress,Received,Status,FromIP,ToIP,Size,Pagina,Subject" -Encoding ASCII

    $objUsers = (Get-Mailbox).primarysmtpaddress     

    Foreach ($objUser in $objUsers){
        $messages= Get-MessageTrace  -SenderAddress $objUser -StartDate (Get-Date).AddHours(-1) -EndDate (get-date) -PageSize 5000 -AsJob
        
    
    # FORMATING OUTPUT OBJECT
    $Output = $Messages | Select-Object @{Name = 'MessageId'; Expression = {
        if ($_.MessageId) {$_.MessageId.trim().Substring(1,($_.MessageId.Length-2))} else {"Missed"}}},Timestamp, MessageSubject, ClientHostname, ServerHostname, Sender, 
        @{Name = 'Recipients'; Expression = {if($_.Recipients) {[string]($_.Recipients)}}},Directionality,Source,EventId,@{Name='Size'; Expression ={
        if ($_.TotalBytes -gt 1GB) {“$([math]::Round(($_.TotalBytes / 1GB),0)) GB”;return}
        if ($_.TotalBytes -gt 1MB) {“$([math]::Round(($_.TotalBytes / 1MB),0)) MB”;return}
        if ($_.TotalBytes -gt 1KB) {“$([math]::Round(($_.TotalBytes / 1KB),0)) KB”;return}
        else {“$([math]::Round(($_.TotalBytes / 1KB),0)) Byte”}}} #converting bytes
    
        # FILTER SERVICE MESSAGES
        If ($HideHealthMessages -eq 'Yes') {
        $Output = $Output | Where-Object {($_.Sender -notmatch 'maildeliveryprobe') -and ($_.Sender -notmatch 'HealthMailbox') -and ($_.Recipients -notmatch 'HealthMailbox') -and ($_.MessageId -ne 'Missed')}
        }
    
        # OUTPUT TO JSON
        #$Output = $Output | ConvertTo-Json
        $Output = export-file -filepath "C:\Logs\Resultado.csv"
        # RETURN
        $Output

        Write-Output "FINALIZADO CORRECTAMENTE SE CERRO LA SESION"
        Remove-PSSession -Session $Session
    }

function ConnectTo-ExchangeOnline {
    Write-Output "INICIANDO SESION"
    $SessionOptions = New-PSSessionOption -IdleTimeout 600000 -NoCompression:$True
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection -SessionOption $sessionOptions
    Import-PSSession $Session
} 

. Main