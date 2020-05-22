# Add relying party trust for Claims Aware Web App
$IssuanceTransformRule = '@RuleName = "All Claims" c:[] => issue(claim = c);'
$IssuanceAuthorizationRule = '@RuleTemplate = "AllowAllAuthzRule"  => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

Add-AdfsRelyingPartyTrust -Name "intranet.corp.contoso.com" -MetadataUrl "https://intranet.corp.contoso.com/claimapp/FederationMetadata/2007-06/FederationMetadata.xml" -IssuanceTransformRules $IssuanceTransformRule -IssuanceAuthorizationRules $IssuanceAuthorizationRule -MonitoringEnabled $true -AutoUpdateEnabled $true

