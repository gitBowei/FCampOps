# Import-Module ServerManager

# Install-WindowsFeature Adcs-Cert-Authority -Source "\\con-hyd-01\DeploymentShare`$\Operating Systems\Windows Server 2012 R2 SERVERSTANDARDCORE x64\sources\sxs" -IncludeManagementTools

# Install-WindowsFeature Adcs-Web-Enrollment -Source "\\con-hyd-01\DeploymentShare`$\Operating Systems\Windows Server 2012 R2 SERVERSTANDARDCORE x64\sources\sxs" -IncludeManagementTools

Import-Module ADCSDeployment

$CACommonName = "Contoso Corp CA"
Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CACommonName $CACommonName -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -KeyLength 2048 -HashAlgorithmName SHA1 -ValidityPeriod Years -ValidityPeriodUnits 5 -Force
Install-AdcsWebEnrollment -Force
