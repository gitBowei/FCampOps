<#
.Synopsis
    This script is use to export all of a site collections
.DESCRIPTION
    This script will export all of the collections, you can export the Basic information of all the collections or the full informations of the collections.
    Also the script let's you export in CSV, HTML or gridview.
    For the time being you need to run this on the primary site.
    The script work on SCCM 2012 and 1511
    Note that this could take a while if you have a lot of collections.
.PARAMETER path
    Specifies a path to save the export (HTML or CSV).
.PARAMETER outtype
    Specifies the type of export you want. You can choose between HTML, CSV or Grid-view
.PARAMETER info
    Specifies if you want the basic information in the export or is you want the full information
.PARAMETER Version
    Specifies the version you will running the script on SCCM 2012 or newer. You only need to specify if you plan on running this on 2012 by default it's set to not2012.        
.EXAMPLE
    Get-Collectionsinformation.ps1 -info Basic -outype HTML -path c:\temp\Collections_info.HTML -version 2012
.EXAMPLE
    Get-Collectionsinformation.ps1 -info Basic -outype csv -path c:\temp\Collections_info.csv
.NOTES
    Author: Frederick Dicaire
    Version: 1.0
 
#>
param (
        [Parameter(Mandatory=$true,HelpMessage="Please select the ammount of informations you want (Basic or Full)")]$info,
        [Parameter(Mandatory=$true,HelpMessage="Please select the export type you want (HTML, CSV or Grid-view)")]$type,
        [Parameter(Mandatory=$true,HelpMessage="Please select the path to save the report")]$path,
        [Parameter(Mandatory=$false,HelpMessage="If you are running on a configuration manager 2012 enter 2012")]$Version = "not2012"
)


#Start of funtion section
function refreshtype([string]$RefreshType)
{    
    switch($RefreshType)
    {
        1 {$RefreshType = "MANUAL"}
        2 {$RefreshType = "PERIODIC"}
        4 {$RefreshType = "CONSTANT_UPDATE"}
        6 {$RefreshType = "PERIODIC + CONSTANT_UPDATE"}
    }
    return $refreshtype
}
function CurrentStatus([string]$CurrentStatus)
{
    switch($CurrentStatus)
    {
        0 {$CurrentStatus = "NONE"}
        1 {$CurrentStatus = "READY"}
        2 {$CurrentStatus = "REFRESHING"}
        3 {$CurrentStatus = "SAVING"}
        4 {$CurrentStatus = "EVALUATING"}
        5 {$CurrentStatus = "AWAITING_REFRESH"}
        6 {$CurrentStatus = "DELETING"}
        7 {$CurrentStatus = "APPENDING_MEMBER"}
        8 {$CurrentStatus = "QUERYING"}
    }
    return $CurrentStatus
} 
function RefreshSchedule([string]$coltype, [string]$colname)
{  
    if ($coltype  -eq 1){$rcol = Get-CMUserCollection -name $colname}
    if ($coltype  -eq 2){$rcol = Get-CMDeviceCollection -name $colname}
    $recurrence = $rcol.RefreshSchedule.SmsProviderObjectPath
    #Looking to see if server is 2012r2 and lower
    if ($version -eq "2012"){$2012 = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection   | where {$_.Name -eq "$colname"};$2012r2 = [wmi]$2012.__path; $recurrence = $2012r2.RefreshSchedule.__CLASS}        
    if ($recurrence -eq "SMS_ST_RecurWeekly")
        {
            $day = $rcol.RefreshSchedule.day
            Switch ($Day)
            {
                "1" {$Day = "Sunday"}
                "2" {$Day = "Monday"}
                "3" {$Day = "TuesDay"}
                "4" {$Day = "WednesDay"}
                "5" {$Day = "ThursDay"}
                "6" {$Day = "FriDay"}
                "7" {$Day = "Saturday"}
             }
             $week = $rcol.RefreshSchedule.ForNumberOfWeeks
             $starttime = $rcol.RefreshSchedule.StartTime -split " "
             return "The collection refresh every $week weeks on $day at $($starttime[1])"
        }
        if($recurrence -eq "SMS_ST_RecurMonthlyByWeekday")
        {
            $day = $rcol.RefreshSchedule.day
            Switch ($Day)
            {
                "1" {$Day = "Sunday"}
                "2" {$Day = "Monday"}
                "3" {$Day = "TuesDay"}
                "4" {$Day = "WednesDay"}
                "5" {$Day = "ThursDay"}
                "6" {$Day = "FriDay"}
                "7" {$Day = "Saturday"}
             }
             $month = $rcol.RefreshSchedule.ForNumberOfMonths
             $starttime = $rcol.RefreshSchedule.StartTime -split " "
             return "The collection refresh every $month month on $day at $($starttime[1])"
        }
        if($recurrence -eq "SMS_ST_RecurMonthlyByDate")
        {
             if ($rcol.RefreshSchedule.MonthDay -eq 0)
             {
                $day = "last"
             }
             else
             {
                $day = $rcol.RefreshSchedule.MonthDay
             }
             $month = $rcol.RefreshSchedule.ForNumberOfMonths
             $starttime = $rcol.RefreshSchedule.StartTime -split " "
             return "The collection refresh every $month month on the $day day at $($starttime[1])"
        }    
        if($recurrence -eq "SMS_ST_RecurInterval")
        {
             $starttime = $rcol.RefreshSchedule.StartTime -split " "
             if (!($rcol.RefreshSchedule.DaySpan -eq 0))
             {
                return "The collection refresh every $($rcol.RefreshSchedule.DaySpan) Day at  $($starttime[1])"
             }
             if (!($rcol.RefreshSchedule.HourSpan -eq 0))
             {
                return "The collection refresh every $($rcol.RefreshSchedule.HourSpan) Hour at  $($starttime[1])"
             }
             
             if (!($rcol.RefreshSchedule.MinuteSpan -eq 0))
             {
                return "The collection refresh every $($rcol.RefreshSchedule.MinuteSpan) Min at  $($starttime[1])"
             }       

        }
}
function maintenance([string]$collname)
{    
    $maint = get-CMMaintenanceWindow -CollectionName $collname
    switch($maint.ServiceWindowType)
    {
        "1" {$Servicetype = "All Deployment"}
        "4" {$Servicetype = "Software update"}
        "5" {$Servicetype = "Task Sequence"}
    }
    $maint = get-CMMaintenanceWindow -CollectionName $collname
    switch($maint.IsEnabled)
    {
        "True" {$enable = "Enable"}
        "False" {$enable = "disable"}        
    }
    Return "The Maintenance windows name: $($maint.name) is $enable and  $($maint.Description) the maintnance windows will last $($maint.Duration) min and is apply to $servicetype"
}

#import config manager module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
#get the site code
$SiteCode = Get-PSDrive -PSProvider CMSITE
#grab the site server
$SiteServer = $SiteCode.Root
#set location to the root of config manager drive
Set-Location "$($SiteCode.Name):\"
#grabing all the collection
$collCollections = Get-WmiObject -Namespace "root\SMS\Site_$SiteCode" -Class SMS_Collection
#Declaring Variables
$report = @()
#Start of actual script
foreach ($collection in $collCollections)
{
    $export = New-Object PSObject
    if(($info -eq "basic") -or ($info -eq "full"))
    {
        $Name = $collection.name ; $export | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
        $collID = $collection.CollectionID ; $export | Add-Member -MemberType NoteProperty -Name "Collection ID" -Value $collid
        $CurrentStatus = CurrentStatus($collection.CurrentStatus) ; $export | Add-Member -MemberType NoteProperty -Name "Current Status" -Value $CurrentStatus
        $Limitingcoll = $collection.LimitToCollectionName ; $export | Add-Member -MemberType NoteProperty -Name "Limiting Collection" -Value $Limitingcoll    
        $refreshtype = RefreshType($collection.refreshtype) ;$export | Add-Member -MemberType NoteProperty -Name "RefreshType" -Value  $refreshtype        
        $RSchedule = RefreshSchedule $collection.CollectionType $collection.name ; $export | Add-Member -MemberType NoteProperty -Name "Refresh Schedule" -Value $RSchedule  
        $collmember = $collection.MemberCount ; $export | Add-Member -MemberType NoteProperty -Name "Number of members" -Value $collmember
    }
    if ($info -eq "full")
    {     
        $comment = $collection.comment ; $export | Add-Member -MemberType NoteProperty -Name "Comments" -Value $Comment    
        $export | Add-Member -MemberType NoteProperty -Name "Number of Service Windows" -Value  $collection.ServiceWindowsCount
        $export | Add-Member -MemberType NoteProperty -Name "Number of Power Plan" -Value  $collection.PowerConfigsCount
        if ($collection.CollectionType -eq 1)
        {
            $coll = Get-CMUserCollection -name $collection.name
            $colllastchange = $coll.LastChangeTime ; $export | Add-Member -MemberType NoteProperty -Name "Last Time collection was modified" -Value $colllastchange
            $collmemeberlastchange = $coll.LastMemberChangeTime ; $export | Add-Member -MemberType NoteProperty -Name "Last time memebership was changed" -Value $collmemeberlastchange
            $colllastrefresh = $coll.LastRefreshTime ; $export | Add-Member -MemberType NoteProperty -Name "Last time the collection was refresh" -Value $colllastrefresh
            $export | Add-Member -MemberType NoteProperty -Name "Collection Type" -Value "User collection"
        }
        if ($collection.CollectionType -eq 2)
        {
            $coll = Get-CMDeviceCollection -name $collection.name
            $colllastchange = $coll.LastChangeTime ; $export | Add-Member -MemberType NoteProperty -Name "Last Time collection was modified" -Value $colllastchange
            $collmemeberlastchange = $coll.LastMemberChangeTime ; $export | Add-Member -MemberType NoteProperty -Name "Last time memebership was changed" -Value $collmemeberlastchange
            $colllastrefresh = $coll.LastRefreshTime ; $export | Add-Member -MemberType NoteProperty -Name "Last time the collection was refresh" -Value $colllastrefresh
            $export | Add-Member -MemberType NoteProperty -Name "Collection Type" -Value "Device collection"
        }
        if(!($collection.ServiceWindowsCount -eq 0))
        {
            $maintnancewindows = maintenance($collection.name) ;$export | Add-Member -MemberType NoteProperty -Name "Maintenance windows" -Value $maintnancewindows
        }
        else
        {
            $export | Add-Member -MemberType NoteProperty -Name "Maintenance windows" -Value "No Maintnance Windows for this collection"   
        }
        if(!($collection.CollectionVariablesCount -eq 0))
        {
            $collvars = Get-CMDeviceCollectionVariable -CollectionName $collection.name
            $variable = ""
            foreach ($collvar in $collvars)
            {
                switch($collvar.ismasked)
                {
                    "false"{$value = $collvar.value}
                    "True" {$value = "HIDDEN"}
                }
            $variable += " Variable Name: $($collvar.name) and it's value is $value "
            }    
            $export | Add-Member -MemberType NoteProperty -Name "Collection Variables" -Value $variable
        }
        else
        {
            $export | Add-Member -MemberType NoteProperty -Name "Collection Variables" -Value "no collection variables"   
        }
        $rules = ([WMI]$collection.__path).CollectionRules
        $dnumber = 0
        $var = ""
        foreach($rule in $rules)
        {
            $obj = New-Object PSObject        
            if($rule.__CLASS -eq "SMS_CollectionRuleDirect")
            {
                 $dnumber += 1
            }
            if($rule.__CLASS -eq "SMS_CollectionRuleQuery")
            {
                 $var += "Rule Name: $($rule.rulename) Query: $($rule.QueryExpression) "                              
            }       
            }
         $export | Add-Member -MemberType NoteProperty -Name "Number of Direct Membership" -Value $dnumber   
         $export | Add-Member -MemberType NoteProperty -Name "Name and Query" -Value $var
    }
    #########Making the export readable          
    $Report += $export
}
#Export in CSV
if($type -eq "csv")
{
    $report |Export-Csv -Path $path -NoTypeInformation
}

#Export into HTML

if($type -eq "HTML")
{
    $HTM = "<style>"
    $HTM  = $HTM  + "BODY{background-color:#D8D8D8;}"
    $HTM  = $HTM  + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
    $HTM  = $HTM  + "TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;}"
    $HTM  = $HTM  + "TD{border-width: 1px;padding: 1px;border-style: solid;border-color: black;}"
    $HTM  = $HTM  + "</style>"

    $report | ConvertTo-HTML -head $HTM -title "Collection export" -body "<H2>Information about all the collection.</H2>"| Out-File $path
}

#Export in grid view
if($type -eq "grid")
{
    $report |Out-GridView
}