Configuration ServerTypeA {
param(
[string[]]$computername,
[switch]$needsbackup
)
Node $computername {
if ($needsbackup)
WindowsFeATURE bACKUP {
eNSURE ='pRESENT'
Name= 'Windows-Server-bACKUP'
}
}
File WebContent{
SourcePath = "c:\WebSource\"
DestinationPath= "c:\Inetpub\wwwroot\"
Recurse=$True
Ensure="Present"
DependsOn="[WindowsFeATURE]bACKUP"
}
}
}

#Generate the MOF
ServerTypeA -computername nomatter -needsbackup

#Copy to Pull Server
$global:guid=[guid]::NewGuid()
$source='c:\dsc\ServerTypeA\nomatter.mof'
$dest="\\dc\c$\program files\windowspowershell\dscservice\Configuration$guid.mof"
copy $source $dest
