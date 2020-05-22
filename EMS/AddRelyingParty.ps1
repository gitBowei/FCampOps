Param(
[string]$ECSIdentifier = "https://Windows-Server-Work-Folders/V1",
[string]$ECSDisplayName = "EnterpriseClientSync"
)

Import-Module ADFS;

$TransformRuleString = '@RuleTemplate = "LdapClaims" @RuleName = "Ldap" c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"), query =";userPrincipalName,displayName,sn,givenName;{0}", param = c.Value);' ;

$AuthorizationRuleString = '@RuleTemplate = "AllowAllAuthzRule" => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit",Value = "true");' ;

Add-ADFSRelyingPartyTrust -Identifier $ECSIdentifier -Name $ECSDisplayName -IssuanceTransformRules $TransformRuleString -IssuanceAuthorizationRules $AuthorizationRuleString -EncryptClaims:$false -EnableJWT:$true -AllowedClientTypes Public -ErrorVariable err -ErrorAction Continue
if ($err.Count -gt 0)
{
    "Add-ADFSRelyingPartyTrust failed! error: $err" | Out-File -FilePath [LogFile] -Append
    exit 1
}