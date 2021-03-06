<######################################################
# Find Lockout Events                                 #
#                                                     #
# Pre-Requisites: Domain Admin Rights, Writeable      #
# C:\temp directory on both the local machine and     #
# the domain controllers.                             #
#                                                     #
# Summary:  Script will prompt for AD username,       #
# the name of the domain controller, and the name     #
# of the domain.  A WMI call will initiate a backup   #
# of the security event log on the domain controller. #
# That backup copy will be moved to the local machine #
# where it is parsed for specific events filtered by  #
# user and/or event.  Output is written to a text file#
# in the local c:\temp directory.  Lastly, the local  #
# copy of the security log is deleted if possible as  #
# a cleanup measure.                                  #
#                                                     #
# Note:  Run on every domain controller and review    #
#        output after each run.                       #
#                                                     #
#                                                     # 
#                                                     #
#                                                     #
#                      -Alex Stone  8/1/2011          #
#######################################################>
 
$error.clear()
 
$user = Read-Host "Please enter the userid of the account in question."
$dc = Read-Host "Please enter the name of the server to be searched."
$domain = Read-Host "Please enter the name of the domain."
 
 
 Set-Location c:\temp\
 $mymachine = $env:COMPUTERNAME
 
 #Use WMI to attach to the remote WMI instance for the event log
 $dclog = Get-WmiObject -ComputerName $dc Win32_NTEventlogFile
 
 #Select security as its own object
 $seclog = $dclog |where-object { $_.LogfileName -match "Security"}
 
 #Strings for paths to be used as temp space.
 $logstr = "c:\temp\"+$dc+"seclog.evt"
 $mvstr = "\\"+$dc+"\c$\temp\"+$dc+"seclog.evt"
 
 #Backup the security log locally to the server.
 $seclog.BackupEventlog($logstr)
 
 #Move the newly created backup to our local machine for processing.
 move $mvstr $logstr -force
 
#Convert user name into SID
$objUser = New-Object System.Security.Principal.NTAccount($domain, $user)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
 
#Search local copy of log for events for that user
$userevents = Get-WinEvent -oldest -FilterHashtable @{Path=$logstr; UserID=$strSID.value}
 
#Write header into output file.
$outpath = "C:\temp\"+$user+"rpt.txt"
"Report for lockouts on user " +$user > $outpath
 
#Loop to find certain eventid that relate to account invalid logins.
if ($userevents -ne $null)
{
foreach ($event in $userevents)
    {
    #Events to find relating to login failures.
    if (($event.id -eq 529) -or ($event.id -eq 530) -or ($event.id -eq 531) -or ($event.id -eq 533) -or ($event.id -eq 534) -or ($event.id -eq 535) -or ($event.id -eq 536) -or ($event.id -eq 537) -or ($event.id -eq 539) -or ($event.id -eq 549) -or ($event.id -eq 644) -or ($event.id -eq 675) -or ($event.id -eq 676) -or ($event.id -eq 681) -or ($event.id -eq 12294))
        {
            $outstring = $event.id.tostring()+"   "+$event.timecreated+"    "+$event.message.tostring()
            $outstring >> $outpath
            
         }
         
      }
 }
 else {"No events detected for "+$user}
 
#Attempt to find specific lockout event type (Event 644).
$lockevents = Get-WinEvent -oldest -FilterHashtable @{Path=$logstr; ID=644}
 
#Loop to find lockout events that relate to specifc target user.
if ($lockevents -ne $null)
{
foreach ($lockevent in $lockevents)
    {
    $properties = $lockevent.properties
    foreach ($prop in $properties)
        {
        if ($prop.value -match $user)
               
            {
            $outstring = $lockevent.id.tostring()+"   "+$lockevent.timecreated+"    "+$lockevent.message.tostring()
            $outstring >> $outpath
            
            }
         } 
     }   
      
 }
 else {"No lock events detected."}
 
 
      
#Section to delete local copy of the security log.
 
#First clear the error stack.
$error.Clear()
#Attempt to delete the local copy of the log.
remove-item $logstr
#If delete was a filure, wait 25 seconds and try again.
if ($error.count -ne 0) 
   {
    "Error deleting local copy of log file.  Waiting 25 seconds and trying again."
    Start-sleep 25
    #Second attempt at delete.
    $error.clear()
    remove-item $logstr
    #If the error counter still indicates a problem, notify the user to delete it manually.
    if ($error.count -ne 0) {"Unable to delete "+$logstr+", you will have to delete it manually."} else {"Deleting local copy of security log complete."}
    }  else {"Deleting local copy of security log complete."}
    
#Final message indicating location of output.    
"See "+$outpath+" for results information."

