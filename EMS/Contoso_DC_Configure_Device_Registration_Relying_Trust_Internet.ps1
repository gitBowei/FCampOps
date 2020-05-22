# Import the AD FS PowerShell module
Import-Module ADFS

# Create the relying party trust rule for Internet access requiring device registration
$IssuanceAuthorizationRule = '@RuleName = "Allow if device is registered to the incoming user" c:[Type == "http://schemas.microsoft.com/2012/01/devicecontext/claims/isregistereduser", Value =~ "^(?i)true$"] => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "PermitUsersWithClaim");'

# Set the new relying party trust rule for the "intranet.corp.contoso.com" relying party trust
Set-AdfsRelyingPartyTrust -TargetName "intranet.corp.contoso.com" -IssuanceAuthorizationRules $IssuanceAuthorizationRule

