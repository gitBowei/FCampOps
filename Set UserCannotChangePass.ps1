#########1#########2#########3#########4#########5#########6#########7#########8#########9#########1
#########0#########0#########0#########0#########0#########0#########0#########0#########0#########0
#
# Author: Erik McCarty
#
# Description: Set the "user Cannot Change Password" property on an active
# directory user object
#
# Remarks: There is poor documentation on the internet that would lead you
# to believe the $user.userAccountControl property value bit 0x000040 can
# be set to turn on the "user Cannot Change Password" account property.
# However you cannot assign this permission by directly modifying the
# userAccountControl attribute.
#
# History:
# 20080107 EWM Initial Creation
#
# reference:
#       http://msdn2.microsoft.com/en-us/library/aa746398.aspx
#       http://mow001.blogspot.com/2006/08/powershell-and-active-directory-part-8.html 
#       http://ewmccarty.spaces.live.com/blog/cns!CE2AE9EFF99E6598!132.entry
# Example:
#
#  Set-UserCannotChangePassword "BMcClellan"
#
#########1#########2#########3#########4#########5#########6#########7#########8#########9#########1
#########0#########0#########0#########0#########0#########0#########0#########0#########0#########0
#
function set-UserCannotChangePassword( [string] $sAMAccountName ){
   # set variables
   $everyOne = [System.Security.Principal.SecurityIdentifier]'S-1-1-0'
   $self = [System.Security.Principal.SecurityIdentifier]'S-1-5-10'
   $SelfDeny = new-object System.DirectoryServices.ActiveDirectoryAccessRule (
                              $self,'ExtendedRight','Deny','ab721a53-1e2f-11d0-9819-00aa0040529b')
   $SelfAllow = new-object System.DirectoryServices.ActiveDirectoryAccessRule (
                              $self,'ExtendedRight','Allow','ab721a53-1e2f-11d0-9819-00aa0040529b')
   $EveryoneDeny = new-object System.DirectoryServices.ActiveDirectoryAccessRule (
                           $Everyone,'ExtendedRight','Deny','ab721a53-1e2f-11d0-9819-00aa0040529b')
   $EveryOneAllow = new-object System.DirectoryServices.ActiveDirectoryAccessRule (
                           $Everyone,'ExtendedRight','Allow','ab721a53-1e2f-11d0-9819-00aa0040529b')
 
   # find the user object in the default domain
   $searcher = New-Object DirectoryServices.DirectorySearcher
   $searcher.filter = "(&(samaccountname=$sAMAccountName))"
   $results = $searcher.findone()
   $user = $results.getdirectoryentry()
 
   # set "user cannot change password"
   $user.psbase.get_ObjectSecurity().AddAccessRule($selfDeny)
   $user.psbase.get_ObjectSecurity().AddAccessRule($EveryoneDeny)
   $user.psbase.CommitChanges()
}

