# New User In PowerShell 
# ye110wbeard (EnergizedTech) Finally shuts up and writes a script that is USEFUL and doesn't sing about it 
# 7/15/2009 :) 
# And it couldn't have happened if it wasn't for the Powershell Community 
# 
# This script in many ways is VERY simple.  I simply chose to use simple assignments instead of a fancy "CSV Import" so a Powershell 
# Newbie might be able to look at it, and get a better grasp of what everything is in Active Directory when THEY want to do something similiar 
# 
# For Newbie Users, a line beginning with a '#' is a comment.   If you put a '#' the line will be ignored. 

# Prompt User for FirstName and LastName of new user 

$FirstName = read-host -Prompt "Enter User First Name: " 
$LastName = read-host -Prompt "Enter User Last Name: " 

# Password must be read from Console as Secure String to be applied.  If you're manipulate this to a Batch User process, you can use this one password as a default.  The Exchange New-Mailbox has the "Change Password at login" enabled by default 

$TempPassword = read-host -AsSecureString -Prompt "Please Enter Temporary Password" 

# SAM name will appear as Firstname.Lastname in Active Directory.   Adjust to meet your needs 

$Sam=$FirstName+"."+$LastName 

$max=$Sam.Length 

#The SAM account cannot be greater than 20 characters.  You have to account for this.  A better functionn would stop query and say "Too big stupid" but this is my first time out 

if ($max -gt 20) {$max=20} 

$Sam=$Sam.Substring(0,$max) 

# This is handy if your organization must have the names listed by Lastname, Firstname.  Exchange 2007 cannot do this natively (as least not that I have found) 

$Name=$Lastname+", "+$FirstName 
$DisplayName=$Lastname+", "+$FirstName 

# User Alias Displaying as Firstname.Lastname 

$Alias=$FirstName+"."+$LastName 

# UPN will be your internal login ID.  Typically Alias@domain.local or Username@domain.com 

$UPN=$FirstName+"."+$LastName+"@Contoso.local" 

# UNC Pathname to a share where all user folders reside.  Path must exist.  Recommend adding $ to sharename to hide from User Browsing 

$HomeDir='\\CONTOSOFILE\USERHOME$\'+$Alias 

# Drive Letter assigned to \\CONTOSOFILE\USERHOME$\USERNAME Folder - Pick one 

$HomeDrive='Z:' 

# Generic inbound office line and format of User Phone Extension.  Display purposes only.   Could be prompted as well 

$Phone='212-555-0000 x111' 

# Your friendly neighbourhood ZIPCODE (or POSTALCODE if you're from Canada 'eh'?) 

$PostalZip='90210' 

# City the user works in.  If you have multiple offices, you could prompt this as well 

$City='Toronto' 

# Your State (no not Confusion, the one you live in) or Province for those 'Canadians' Again 

$StateProv='Ontario' 

# Address you work at 

$Address='123 Sesame Street' 

# Default web site 

$Web='www.contosorocks.com' 

# Company where you work at, or won't work at if your boss catches you spending too much time drooling over Powershell 

$Company='Contoso Rocks Ltd' 

# What location in the building?  typically floor X, Division Y, the back room behind the boxes 

$Office='In the Basement with my stapler' 

# A generic description for the user 

$Description='New User' 

# Job Description.  Carpet burner, box stacker, cable monkey 

$JobTitle='New User Hired' 

# What department.  Where you hiding?  Network Admins, Secretaries? 

$Department='New Department Hire' 

# Office Fax Number 

$Fax='212-555-1234' 

# The ending part of the domain @wherever.com @fabrikam.com etc etc 

$ourdomain='@contoso.local' 

# This first line is done within the Microsoft Exchange Management Shell from Exchange 2007.  I add it's ability to my Powershell with the command 
# ADD-PSSNAPIN -name Microsoft.Exchange.Management.Powershell.Admin IF you have the Microsoft Exchange console on the computer running this script.  And you have Microsoft Exchange Server 2007 in the environment 

New-Mailbox -Name $Name -Alias $Alias -OrganizationalUnit 'Contoso.local/Users' -UserPrincipalName $UPN -SamAccountName $SAM -FirstName $FirstName -Initials '' -LastName $LastName -Password $TempPassword -ResetPasswordOnNextLogon $true -Database 'CONTOSOEXCHANGE\First Storage Group\Mailbox Database' 

# This command l 

set-qaduser -identity $alias -homedirectory $HomeDir -homedrive $Homedrive -city $City -company $Company -department $Department -fax $Fax -office $Office -phonenumber $Phone -postalcode $PostalZip -stateorprovince $StateProv -streetaddress $Address -webpage $web -displayname $displayname -title $JobTitle 

#http://www.powergui.org/thread.jspa?messageID=14099 Source post for creating OCS user with Powershell!  Thank you Powergui.ORG! 
# 
# Tips.  If you do have Office Communications Server or Live Comm and looking for the Variables used, Check an enabled user in Active Directory while in ADVANCED mode 
# and choose the "Attribute Editor" tab.  You'll find them all down there.   If it doesn't say "Enabled" or contain a value?  Don't use it 

$SIPHOMESERVER='CN=LC Services,CN=Microsoft,CN=CONTOSO-OCSSERVER,CN=Pools,CN=RTC Service,CN=Microsoft,CN=System,DC=CONTOSO,DC=local' 

$oa = @{'msRTCSIP-OptionFlags'=384; 'msRTCSIP-PrimaryHomeServer'=$SIPHOMESERVER; 'msRTCSIP-PrimaryUserAddress'=("sip:"+$alias+$ourdomain); 'msRTCSIP-UserEnabled'=$true } 

Set-QADUser $Alias -oa $oa 

#http://blogs.msdn.com/johan/archive/2008/10/01/powershell-editing-permissions-on-a-file-or-folder.aspx - Great reference on SETTING NTFS permissions with SET-ACL! Thumbs up! 

#Make User Home Folder and Apply NTFS permissions - This was taken almost VERBATIM from the Blogpost.  I added in the $alias created from the FirstName Lastname to automatically populate a HomeFolder based upon the user name 

$HomeFolderMasterDir='\\CONTOSOFILE\USERHOME$\' 

new-item -path $HomeFolderMasterDir -name $Alias -type directory 

$Foldername=$HomeFolderMasterDir+$Alias 
$DomainUser='CONTOSO\'+$Alias 

$ACL=Get-acl $Foldername 
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($DomainUser,"FullControl","Allow") 
$Acl.SetAccessRule($Ar) 
Set-Acl $Foldername $Acl