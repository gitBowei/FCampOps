    Write-Progress -activity "Iniciando aplicacion"
    Write-Output "Cierre de sesiones previas"
    Get-PSSession | Remove-PSSession
    $InputFile = "C:\Logs\PrimarySMTP.csv"
    $EndDate=(get-date).addhours(-1)
    $StartDate=(get-date).addhours(-2).addminutes(45)
    $pw = convertto-securestring -AsPlainText -Force -String “Csj-20#20$”
    $SessionOptions = New-PSSessionOption -IdleTimeout 600000 -NoCompression:$True
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "msgtracereporting@etbcsj.onmicrosoft.com",$pw
    Write-Progress -activity "Conectamos a Exchange Online"
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -SessionOption $sessionOptions -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential ($cred) -Authentication Basic -AllowRedirection
    Write-Progress -activity "Importamos el metodo"
    Connect-MSOLservice –Credential $cred
    Import-PSSession $Session
    Write-output "Son las: " (Get-date)
    $objUsers = import-csv $InputFile 
    ##$objusers=get-msoluser -enabledfilter EnabledOnly -MaxResults 20000 |Select UserPrincipalName
    ##$objusers
    Write-output "termine de listarlos usuarios a las: " (Get-date)
    Write-Output ($objusers).count
    
    Foreach ($objUser in $objUsers){
                for($c=1;$c -lt 1001; $c++){
                    $mensa = "ENVIADOS DE: " + $objUser + " EN LA PAGINA: " + [String]$c
                    Write-Progress -activity $mensa 
                    Write-Output $mensa
                    $messages=Get-MessageTrace -senderAddress $objUser -StartDate $StartDate -EndDate $EndDate -PageSize 5000 -Page $c
                    ##if(($messages).count -gt 0){
                        if($messages -eq $null){
                            break;
                            }
                        
                        else{            
                        Write-Output "Se esta grabando al archivo..."
                        Get-MessageTrace -senderAddress $objUser -StartDate $StartDate -EndDate $EndDate  -PageSize 5000 -Page $c | Select-Object MessageTraceId,MessageID,SenderAddress,RecipientAddress,Subject,Received,Status,FromIP,ToIP,Size, @{l="Page";e={$c}} | Export-Csv -path "c:\logs\salida.csv" -Encoding UTF8 -Append -NoTypeInformation
                    }
        }
    }
    Write-Output "FINALIZADO CORRECTAMENTE SE CERRO LA SESION"
    Get-PSSession | Remove-PSSession