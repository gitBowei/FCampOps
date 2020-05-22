#pide los datos de las variables de usuario y contraseña para iniciar sesion en powersehll y el nombre del archivo a cargar
Param( 
           
    [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $InputFile,
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $StartDate,
    [Parameter(Position=2, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $EndDate,
    [Parameter(Position=3, Mandatory=$false, ValueFromPipeline=$true)] 
    [string] $OutputFile

) 


$Subject="*";


Function Main { 

    Write-Progress -activity "ENTRANDO AL METODO PRINCIPAL"
    Write-Output "CERRANDO SESION ACTIVA"
    Get-PSSession | Remove-PSSession 
     
   
    ConnectTo-ExchangeOnline -Office365AdminUsername $Office365Username -Office365AdminPassword $Office365Password    
   ## Out-File -FilePath $OutputFile -InputObject "MessageTraceId,MessageID,SenderAddress,RecipientAddress,Received,Status,FromIP,ToIP,Size,Pagina,Subject" -Encoding ASCII

        
    if ($InputFile -ne "") 
    { 
        Write-Output -activity "VALIDANDO ARCHIVO PLANO ESPERE UN MOMENTO......"

        $objUsers = import-csv -Header "UserPrincipalName" $InputFile 
    } 
    else 
    { 
        Write-Output -activity "NO SE CARGO NUNGUNA CUENTA EN EL ARCHIVO PLANO SE VA A CERRAR LA SESION REMOTA"
           Write-Output "FINALIZADO CORRECTAMENTE SE CERRO LA SESION"
            Get-PSSession | Remove-PSSession 
    } 



Foreach ($objUser in $objUsers){
         
 for($c=1;$c -lt 1001; $c++){
   
                    $mensa = "ENVIADOS DE: " + $objUser.UserPrincipalName + " EN LA PAGINA: " + [String]$c
                    Write-Progress -activity $mensa 
                    Write-Output $mensa
    

    $messages=Get-MessageTrace  -SenderAddress  $($objUser.UserPrincipalName)  -StartDate $StartDate -EndDate $EndDate  -PageSize 5000 -Page $c

  ##if(($messages).count -gt 0){
    if($messages -eq $null){       
            break;

                }else{

            
                        Get-MessageTrace  -SenderAddress  $($objUser.UserPrincipalName)  -StartDate $StartDate -EndDate $EndDate  -PageSize 5000 -Page $c | Select-Object MessageTraceId,MessageID,SenderAddress,
                         RecipientAddress,Subject,Received,Status,FromIP,ToIP,Size, @{l="Page";e={$c}} | Export-Csv "$OutputFile" -Encoding UTF8 -appen  -NoTypeInformation
                    }

                
        }
       
     
  }
    

    
    Write-Output "FINALIZADO CORRECTAMENTE SE CERRO LA SESION"
    Get-PSSession | Remove-PSSession 
}




function ConnectTo-ExchangeOnline 
{    
    
       Write-Output "INICIANDO SESION"  
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy unrestricted -Force
$pw = convertto-securestring -AsPlainText -Force -String “CcsjC3nd0j*” 
$SessionOptions = New-PSSessionOption -IdleTimeout 600000 -NoCompression:$True
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "traza5@etbcsj.onmicrosoft.com",$pw
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -SessionOption $sessionOptions -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential ($cred) -Authentication Basic -AllowRedirection
Connect-MSOLservice –Credential $cred
Import-PSSession $Session
} 
 
 

. Main