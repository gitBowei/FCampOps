# Import the ADFS PowerShell module
Import-Module ADFS

#Add the Enterprise Sync Relying Party Trust to ADFS
$ECSIdentifier = "https://Windows-Server-Work-Folders/V1"
$ECSDisplayName = "workfolders.corp.contoso.com"

# Declare the variables used to establish the 
$TransformRuleString = '@RuleTemplate = "LdapClaims" @RuleName = "Ldap" c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"), query =";userPrincipalName,displayName,sn,givenName;{0}", param = c.Value);'
$AuthorizationRuleString = '@RuleTemplate = "AllowAllAuthzRule" => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit",Value = "true");' ;

Add-ADFSRelyingPartyTrust -Name $ECSDisplayName -Identifier $ECSIdentifier -IssuanceTransformRules $TransformRuleString -IssuanceAuthorizationRules $AuthorizationRuleString -EncryptClaims $false -EnableJWT $true -AllowedClientTypes Public -ErrorVariable Err -ErrorAction Continue
