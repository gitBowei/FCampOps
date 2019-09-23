import-module SMLets
#
# A nice trick borrowed from http://poshtips.com/2010/03/30/measuring-elapsed-time-in-powershell/
$ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
write-host "Start - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
# Some variables
$CRM_firstname = "Flash"
$CRM_lastname = "Gordon"
$CRM_company = "01235 - QBT Inc."
$Domain = "SMInternal"
$AD_Domain="NORWEGIANFJORD"
$UserName = "qbt.flashg"
# $Company = "QBT Inc"
$BusinessPhone = "55555226"
# Some email variables
$CRM_Epost_ChannelName = "SMTP"
$CRM_Epost_DisplayName = "CRM_Email_address_226"
$CRM_Epost_TargetAddress = "flash.1978.gordon@gmail.com"
$CRM_Epost_Description = "This Emailaddress is importet from Contacts in CRM"
# Some Incident variables
$CRM_Title = "Test 226 A good title" 
$CRM_Description = "Test 226 A good description"
$Some_Support_dude = "gordon ramsey"
write-host "Variabler satt - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
# New User
# Author: Anton Gritsenko - FreemanRU
# http://social.technet.microsoft.com/Forums/en-US/systemcenterservicemanager/thread/364fa4b9-8170-4369-8d9c-53fbb0d0ec17
write-host "Part 1 - new user"
# Check on user
write-host "Part 1 - start - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
$Check_AD_Domain = (Get-SCSMObject -Class (Get-SCSMClass -Name System.Domain.User$)-Filter "FirstName -eq '$CRM_firstname' and lastname -eq '$CRM_lastname' and Domain -eq '$AD_Domain'").username
write-host "Check_AD_Domain: " $Check_AD_Domain
write-host "Part 1 - AD_domain - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
$Check_SMinternal = (Get-SCSMObject -Class (Get-SCSMClass -Name System.Domain.User$) -Filter "FirstName -eq '$CRM_firstname' and lastname -eq '$CRM_lastname' and Domain -eq '$Domain'").username
write-host $Check_SMinternal
write-host "Part 1 - done - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
If($Check_AD_Domain  -eq $null -and $Check_SMinternal -eq $null )
    {
    Write-Host 'User is not in AD or SMinternal, user will get account in SMinteral: ' 
    $curClass = get-scsmclass "System.Domain.User"
$param=@{Domain=$Domain;
    UserName=$UserName;
    #        DisplayName=$DisplayName;
    FirstName=$CRM_firstname;
    LastName=$CRM_lastname;
    Company=$CRM_company;
    BusinessPhone=$BusinessPhone;}
new-scsmobject -Class $curClass -PropertyHashtable $param
}
        else
        {
        write-host "Bruker finnes alt i AD eller SMInternal: "$Check_AD_Domain 
        }
# Epost
# Borrowed from Anton Gritsenko - FreemanRU
# http://freemanru.wordpress.com/2010/12/11/use-type-projection/
write-host "Part 2 - email"
write-host "Part 2 start - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
$managementGroup = new-object Microsoft.EnterpriseManagement.EnterpriseManagementGroup "localhost"
$userPrefRel = Get-SCSMRelationshipClass "System.UserHasPreference"
$userClass =  Get-SCSMClass System.Domain.User
[Microsoft.EnterpriseManagement.Configuration.ManagementPackType]$endpointClass = get-scsmclass -Name "System.Notification.Endpoint"
$userRefProj = $managementGroup.EntityTypes.GetTypeProjections() | ? {$_.Name -eq "System.User.Preferences.Projection"}
$sysMP = $managementGroup.ManagementPacks.GetManagementPack([Microsoft.EnterpriseManagement.Configuration.SystemManagementPack]::System)
$criteriaString = '<Criteria xmlns="http://Microsoft.EnterpriseManagement.Core.Criteria/">
<Reference Id="System.Library" Version="{0}" PublicKeyToken="{1}" Alias="System" />
  <Expression>
    <And>
      <Expression>
        <SimpleExpression>
          <ValueExpressionLeft>
            <Property>$Context/Property[Type=''System!System.ConfigItem'']/ObjectStatus$</Property>
          </ValueExpressionLeft>
          <Operator>NotEqual</Operator>
          <ValueExpressionRight>
            <Value>{{47101e64-237f-12c8-e3f5-ec5a665412fb}}</Value>
          </ValueExpressionRight>
        </SimpleExpression>
      </Expression>
      <Expression>
        <SimpleExpression>
          <ValueExpressionLeft>
            <Property>$Context/Property[Type=''System!System.Domain.User'']/Domain$</Property>
          </ValueExpressionLeft>
          <Operator>Equal</Operator>
          <ValueExpressionRight>
            <Value>{2}</Value>
          </ValueExpressionRight>
        </SimpleExpression>
      </Expression>
      <Expression>
        <SimpleExpression>
          <ValueExpressionLeft>
            <Property>$Context/Property[Type=''System!System.Domain.User'']/UserName$</Property>
          </ValueExpressionLeft>
          <Operator>Equal</Operator>
          <ValueExpressionRight>
            <Value>{3}</Value>
          </ValueExpressionRight>
        </SimpleExpression>
      </Expression>
    </And>
  </Expression>
</Criteria>'
function Set-SCSMSMTPAddressToUser
{
param ([parameter(Mandatory=$true,Position=0)][string]$UserDomain,
       [parameter(Mandatory=$true,Position=1)][string]$UserName,
       [parameter(Mandatory=$true,Position=2)][string]$AddressDisplayName,
       [parameter(Mandatory=$true,Position=3)][string]$SMTPAddress,
       [parameter(Mandatory=$false,Position=4)][string]$AddressDescription="")
[string]$criteria = [string]::Format($criteriaString, $sysMP.Version, $sysMP.KeyToken, $UserDomain, $UserName)
    [Microsoft.EnterpriseManagement.Common.ObjectProjectionCriteria]$criteriaObj = new-object Microsoft.EnterpriseManagement.Common.ObjectProjectionCriteria($criteria, $userRefProj,$managementGroup)
$userPref = Get-SCSMObjectProjection  -Criteria $criteriaObj
$guid = [Guid]::NewGuid().ToString("N")
$newChannel = new-object Microsoft.EnterpriseManagement.Common.CreatableEnterpriseManagementObject($managementGroup, $endpointClass)
    $newChannel.Item($endpointClass, "Id").Value = "Notification.$guid"
    $newChannel.Item($endpointClass, "ChannelName").Value = $CRM_Epost_ChannelName
    $newChannel.Item($endpointClass, "DisplayName").Value = $CRM_Epost_DisplayName
    $newChannel.Item($endpointClass, "TargetAddress").Value = $CRM_Epost_TargetAddress
    $newChannel.Item($endpointClass, "Description").Value = $CRM_Epost_Description
$userPref.__base.Add($newChannel, $userPrefRel.Target)
    $userPref.__base.Commit()
}
# Check on user
write-host "Part 2 Check displayname - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
$display_name1 = (Get-SCSMObject -Class (Get-SCSMClass -Name System.Domain.User$) -Filter "FirstName -eq '$CRM_firstname' and lastname -eq '$CRM_lastname' and Company -eq '$CRM_company'").displayname
write-host "displaynamename: " $display_name1
$userpreferenceclass = get-scsmrelationshipclass -name system.userhaspreference$
$class = get-scsmclass -name system.user$
$user = Get-SCSMObject -class $class -filter  displayname -eq $display_name1 
$mail_id = (Get-scsmrelatedobject  smobject $user  relationship $userpreferenceclass | where{$_.channelname  match  SMTP }).ID
$mail_target = (Get-scsmrelatedobject  smobject $user  relationship $userpreferenceclass | where{$_.channelname  match  SMTP }).targetaddress
If($mail_id  -eq $null)
        {
        Write-Host 'Mail_target is nill for!: ' $username1 "Will now set emailaddress"
         
        # Set-SCSMSMTPAddressToUser "SMinternal" "gricenko" "Some New Address" "test@domain.lan"
        Set-SCSMSMTPAddressToUser "SMinternal" $username "Some Newy4 Address" "test3@domainy.com"
        Write-Host "Emailaddress set for user: " $username 
        
       
        }
        else
        {
        write-host "User has allready emailadress: "$mail_target
        write-host "Changes to this has to be done in SCSM"
        write-host "mail_id in SCSM is: " $mail_id
        }
write-host "Part 2 - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
# Part 3 - Incident
write-host "Part 3 Elapsed Time - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
$Incident_AffectedUser_displayname = (Get-SCSMObject -Class (Get-SCSMClass -Name System.Domain.User$) -Filter "FirstName -eq '$CRM_firstname' and lastname -eq '$CRM_lastname' and Company -eq '$CRM_company'").displayname
write-host $Incident_AffectedUser_displayname
New-SCSMIncident -Title $CRM_Title -Description $CRM_Description -Impact Low -Urgency Low -Classification Other -Source Phone 
# Incident - AffetedUser og AssignedToUser
write-host "Part 4 - Incident AffetedUser og AssignedToUser"
write-host "Part 4 - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
get-scsmincident -title $CRM_Title  | set-incidentuser  -Affected $Incident_AffectedUser_displayname -AssignedTo $Some_Support_dude
# The End
write-host "Part 5 - "
$Id_paa_sak = (get-scsmincident -title $CRM_Title).ID
write-host "The Incident has ID : " $Id_paa_sak
write-host "The Script used - Elapsed Time: $($ElapsedTime.Elapsed.ToString())"
