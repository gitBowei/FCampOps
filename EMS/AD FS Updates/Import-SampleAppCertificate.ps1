# Define variables that are needed in this script
$CertExportPath = "\\dc\Source$\SampleApps"
$RootCertFileName = "Tiles_Sample.cer"
$TrustedRootCertificateStore = "Cert:\LocalMachine\root"

# Import the self-signed certificate for the sample apps
# into our local "Trusted Root Certification Authorities" store
Import-Certificate -FilePath $($CertExportPath + "\" + $RootCertFileName) -CertStoreLocation $TrustedRootCertificateStore | Out-Null

