# Service Manager Administrator Module                                                                                                                                                                                                                                                                                                                                                
import-module 'C:\Program Files\Microsoft System Center 2012 R2\Service Manager\Powershell\System.Center.Service.Manager.psd1'   

$cred=get-credential -Credential Glup\fcampo

# Luego hay que realizar la conexion al servidor SCSM de la organizacion...
New-SCManagementGroupConnection -ComputerName "Piazzolla.Glup.it" -Credential $cred

#The following script creates a new Request in SCSM and writes out the request ID
#Get the Request Class
$REQClass = get-scsmclass -Name System.WorkItem.ServiceRequest$

#Set the ID of the Request
$id = "REQ{0}"

#Set the title and description of the Request
$title = "Request From PowerShell Script"
$description = "This request was created from a PowerShell Script"

#Set the impact and urgency of the request
$impact = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.ImpactEnum.Medium
$urgency = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.UrgencyEnum.Medium

#Create a hashtable of the Request values
$RequestHashTable = @{
Id = $id
Title = $title
Description = $description
Impact = $impact
Urgency = $urgency
}

#Create the Request
$newRequest = New-SCSMObject $REQClass -PropertyHashtable $RequestHashTable –PassThru

Write-Host $newRequest

# Este es otro Script..
import the smlets import-module smlets;
#Get the Service Request Class
$serviceRequestClass = Get-SCSMClass -name System.WorkItem.ServiceRequest$
#Get the enumeration values needed for the lists in the Service Request
$serviceRequestArea = get-SCSMEnumeration -Name ServiceRequestAreaEnum.Infrastructure.Backups 
$serviceRequestPriority = Get-SCSMEnumeration -Name ServiceRequestPriorityEnum.High
$serviceRequestUrgency = Get-SCSMEnumeration -Name ServiceRequestUrgencyEnum.High
#Specify the title
$serviceRequestTitle = “New Infrastructure Server Backup Component”
$serviceRequestDescription = "I am a service request for a new infrastructure Backup component, created by PowerShell"
#Create a hash table of the Service Request Arguments
$serviceRequestHashTable = @{
     Title = $serviceRequestTitle;
     Description = $serviceRequestDescription;
     Urgency = $serviceRequestUrgency;
     Priority = $serviceRequestPriority;
     ID = “SR{0}”;
     Area = $serviceRequestArea
    }
#Create initial Service Request
$newServiceRequest = New-SCSMOBject -Class $serviceRequestClass -PropertyHashtable $serviceRequestHashTable -PassThru
$serviceRequestId = $newServiceRequest.ID
#Get The Service Request Type Projection
$serviceRequestTypeProjection = Get-SCSMTypeProjection -name System.WorkItem.ServiceRequestProjection$
#Get the Service Request created earlier in a form where we can apply the template
$serviceRequestProjection = Get-SCSMObjectProjection -ProjectionName $serviceRequestTypeProjection.Name -filter “ID -eq $serviceRequestId”
#Get The Service Request Template
$serviceRequestTemplate = Get-SCSMObjectTemplate -DisplayName “SR - Create Service Request Using PowerShell Template”
#Apply the template to the Service Request
Set-SCSMObjectTemplate -Projection $serviceRequestProjection -Template $serviceRequestTemplate
