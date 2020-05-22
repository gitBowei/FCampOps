Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"

Set-Location "NYC:"

Add-CMDeploymentType -ApplicationName "Microsoft Skype" -AndroidDeepLinkInstaller -AutoIdentifyFromInstallationFile -ForceForUnknownPublisher $true -InstallationFileLocation "https://play.google.com/store/apps/details?id=com.skype.raider"

Add-CMDeploymentType -ApplicationName "Microsoft Skype" -iOSDeepLinkInstaller -AutoIdentifyFromInstallationFile -ForceForUnknownPublisher $true -InstallationFileLocation "https://itunes.apple.com/us/app/skype/id304878510?mt=8"
