# Service Manager Administrator Module                                                                                                                                                                                                                                                                                                                                                
import-module 'C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Powershell\System.Center.Service.Manager.psd1'                                                                                                                                                                                                                                                        

# Service Manager Data Warehouse Module                                                                                                                                                                                                                                                                                                                                               
import-module 'C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1'                                                                                                                                                                                                                                                
Get-Command -module System.Center.Service.Manager                                                                                                                                                                                                                                                                                                                                     

# Service Manager Administrator Module                                                                                                                                                                                                                                                                                                                                                
$InstallationConfigKey = 'HKLM:\SOFTWARE\Microsoft\System Center\2010\Service Manager\Setup'                                                                                                                                                                                                                                                                                          
$AdminModule = (Get-ItemProperty -Path $InstallationConfigKey -Name InstallDirectory).InstallDirectory + "Powershell\System.Center.Service.Manager.psd1"                                                                                                                                                                                                                              
Import-Module -Name $AdminModule                                                                                                                                                                                                                                                                                                                                                      

# Service Manager Data Warehouse Module                                                                                                                                                                                                                                                                                                                                               
$InstallationConfigKey = 'HKLM:\SOFTWARE\Microsoft\System Center\2010\Service Manager\Setup'                                                                                                                                                                                                                                                                                          
$DWModule = (Get-ItemProperty -Path $InstallationConfigKey -Name InstallDirectory).InstallDirectory + "Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1"                                                                                                                                                                                                                         
Import-Module -Name $DWModule

# Import the module
Import-Module -Name smlets

# Luego hay que realizar la conexion al servidor SCSM de la organizacion...
$ServerConfigKey = 'HKCU:\Software\Microsoft\System Center\2010\Service Manager\Console\User Settings'
$SvcMgmtSrv = (Get-ItemProperty -Path $ServerConfigKey).SDKServiceMachine
New-SCManagementGroupConnection -ComputerName $SvcMgmtSrv

# Pero si te sabes el nombre del server
New-SCManagementGroupConnection -ComputerName "Piazzolla.Glup.it"

#Aqui un todo en un solo SCRIPT
if(@(get-module | where-object {$_.Name -eq 'System.Center.Service.Manager'}  ).count -eq 0)
{
    $InstallationConfigKey = 'HKLM:\SOFTWARE\Microsoft\System Center\2010\Service Manager\Setup'
    $InstallPath = (Get-ItemProperty -Path $InstallationConfigKey -Name InstallDirectory).InstallDirectory + "Powershell\System.Center.Service.Manager.psd1"
    Import-Module -Name $InstallPath -Global
}

# add command to load Service Manager modules to profile
@'
$InstallationConfigKey = 'HKLM:\SOFTWARE\Microsoft\System Center\2010\Service Manager\Setup'
if(Test-Path $InstallationConfigKey)
{
$AdminModule = (Get-ItemProperty -Path $InstallationConfigKey -Name InstallDirectory).InstallDirectory + "Powershell\System.Center.Service.Manager.psd1"
Import-Module -Name $AdminModule -Global
$DWModule = (Get-ItemProperty -Path $InstallationConfigKey -Name InstallDirectory).InstallDirectory + "Microsoft.EnterpriseManagement.Warehouse.Cmdlets.psd1"
Import-Module -Name $DWModule -Global
}
else
{
throw "ERROR: Could not locate Service Manager PowerShell module on cur"
}
'@ | out-file $profile -Append

# Query SCSM Commands
Get-Command -module System.Center.Service.Manager                                                                                                                                                                                                                                                                                                                                     
Get-Command ?module Microsoft.EnterpriseManagement.Warehouse.Cmdlets                                                                                                                                                                                                                                                                                                                  
Get-Command -module System.Center.Service.Manager 

# Query an Incident ticket
Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq REQ6741" |fl

# Get a specific Incident Request
$IncidentRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Incident$) -filter "ID -eq IR31437"

# Getting the GUID of this Work Item
$IncidentRequest.get_id()

# Get a specific Service Request
$ServiceRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq SR31467"

# Getting the GUID of this Work Item
$ServiceRequest.get_id()

# Get a specific review activity
$ReviewActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ReviewActivity$) -filter "ID -eq RA31724"

# Get the GUID of this Work Item
$ReviewActivity.get_id()

# Get a specific manual activity
$ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq MA45345"

# Get the GUID of this Work Item
$ManualActivity.get_id()

# Get a Runbook Activity
$RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'

# Retrieve the ID property
$RunbookActivity.id

# Retrieve the GUID
$RunbookActivity.get_id()

# Query a Domain User from the CMDB
$DomainUser = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.AD.User$) -Filter "LastName -eq Cat"

# Get the GUID of this CI
$DomainUser.id

# Get a computer object from the CMDB
$ComputerObject = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.Windows.Computer$) -Filter "Displayname -eq MTLLAP8500"

# Retrieve the ID
$ComputerObject.id

# Retrieve the ID using the Get_ID() method.
$ComputerObject.get_id()

# Get a specific manual activity
$ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq MA51163"
# Change the status of the Manual Activity
Set-SCSMObject -SMObject $ManualActivity -Property Status -Value Completed

# Get a specific Service Request
$ServiceRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq REQ6741"
# Change the status of the Service Request to Completed
Set-SCSMObject -SMObject $ServiceRequest -Property Status -Value "In Progress"

# Retrieve Activity Status
Get-SCSMEnumeration -Name ActivityStatusEnum

# Retrieve Service Request Status
Get-SCSMEnumeration -Name ServiceRequestStatusEnum

#The following script creates a new incident in SCSM and writes out the incident ID
#Get the Incident Class
$IRClass = get-scsmclass -Name System.WorkItem.Incident$
# Podria usar :
# System.WorkItem.Problem$
# System.WorkItem.ChangeRequest$
# System.WorkItem.ServiceRequest$
# System.WorkItem.ReleaseRecord$

#Set the ID of the Incident
$id = "IR{0}"

#Set the title and description of the incident
$title = "Incident From PowerShell Script"
$description = "This incident was created from a PowerShell Script"

#Set the impact and urgency of the incident
$impact = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.ImpactEnum.Medium
$urgency = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.UrgencyEnum.Medium

#Create a hashtable of the incident values
$incidentHashTable = @{
Id = $id
Title = $title
Description = $description
Impact = $impact
Urgency = $urgency
}

#Create the incident
$newIncident = New-SCSMObject $IRClass -PropertyHashtable $incidentHashTable –PassThru

Write-Host $newIncident

#Mas informacion en https://docs.microsoft.com/en-us/system-center/scsm/sm-cmdlets 

# Import the module
Import-Module -Name smlets

# Query an Incident ticket
Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq REQ6741" |fl

# Get a specific Incident Request
$IncidentRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Incident$) -filter "ID -eq IR31437"

# Getting the GUID of this Work Item
$IncidentRequest.get_id()

# Get a specific Service Request
$ServiceRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq SR31467"

# Getting the GUID of this Work Item
$ServiceRequest.get_id()

# Get a specific review activity
$ReviewActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ReviewActivity$) -filter "ID -eq RA31724"

# Get the GUID of this Work Item
$ReviewActivity.get_id()

# Get a specific manual activity
$ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq MA45345"

# Get the GUID of this Work Item
$ManualActivity.get_id()

# Get a Runbook Activity
$RunbookActivity = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.SystemCenter.Orchestrator.RunbookAutomationActivity$) -filter 'ID -eq RB30579'

# Retrieve the ID property
$RunbookActivity.id

# Retrieve the GUID
$RunbookActivity.get_id()

# Query a Domain User from the CMDB
$DomainUser = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.AD.User$) -Filter "LastName -eq Cat"

# Get the GUID of this CI
$DomainUser.id

# Get a computer object from the CMDB
$ComputerObject = Get-SCSMObject -Class (Get-SCSMClass -Name Microsoft.Windows.Computer$) -Filter "Displayname -eq MTLLAP8500"

# Retrieve the ID
$ComputerObject.id

# Retrieve the ID using the Get_ID() method.
$ComputerObject.get_id()



# Get a specific manual activity
$ManualActivity = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Activity.ManualActivity$) -filter "ID -eq MA51163"
# Change the status of the Manual Activity
Set-SCSMObject -SMObject $ManualActivity -Property Status -Value Completed

# Get a specific Service Request
$ServiceRequest = Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.ServiceRequest$) -filter "ID -eq REQ6741"
# Change the status of the Service Request to Completed
Set-SCSMObject -SMObject $ServiceRequest -Property Status -Value "In Progress"

# Retrieve Activity Status
Get-SCSMEnumeration -Name ActivityStatusEnum

# Retrieve Service Request Status
Get-SCSMEnumeration -Name ServiceRequestStatusEnum