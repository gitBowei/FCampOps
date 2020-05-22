Add-KdsRootKey –EffectiveTime (Get-Date).AddHours(-10)

New-ADServiceAccount FsGmsa -DNSHostName adfs.corp.contoso.com -ServicePrincipalNames "http/adfs.corp.contoso.com"
