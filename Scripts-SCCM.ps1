###Get-Command -module ConfigurationManager |Out-Gridview

###Get-CMBoundary
###New-CMBoundary
#----------------------------------------------------------------------------------------------------------------
#ConfigMgrModule
#Step 1
Import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.Psd1'

#Step 2
Set-location PS1:\

#Step 3
New-CMPackage -Name 'Visio' -Manufacturer 'Microsoft' -Language 'English' `
-Version 2013 -Path '\\CM01\Sources\Applications\Visio'

#-----------------------------------------------------------------------------------------------------------------







#----------------------------------------------------------------------------------------------------------------
#Despliegue de imagenes SCCM+OSD

#Step 1

Import-module $env:SMS_ADMIN_UI_PATH.Replace('\bin\i386','\bin\configurationmanager.psd1')
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

#Step 2

$ImageName ='Windows 7x64 Enterprise'

New-CMOperatingSystemImage -Name $ImageName -Path '\\CM01\Sources\OSD\Images\Windows7\X64\Install.Wim'

#Step 3
Start-CMContentDistribution -OperatingSystemImageName $ImageName -DistributionPointName 'CM01.corp.campohenriquez.lab'

#Step 4
$CMBoot = Get-CMBootImage -Name 'Boot Image (x64)'
$CMPackage = Get-CMPackage -Name 'Configuration Manager Client Package'
$OSImage = Get-CMOperatingSystemImage -Name $ImageName

New-CMTaskSequence -InstallOperatingSystemImageOption -TaskSequenceName $ImageName `
-PartitionAndFormatTarget $True -BootImagePackageId $CMBoot.PackageID `
-OperatingSystemImageIndex 1 -GeneratePassword $true -WorkgroupName 'Test' -ClientPackagePackageID $CMPackage.PackageID `
-OperatingSystemImagePackageId $OSImage.PackageID -JoinDomain WorkgroupType -ConfigureBitlocker $Fales -SoftwareUpdatestyle All

#Step 5
New-CMDeviceCollection -Name $ImageName -LimitingCollectionName 'All WorkStations'

#Step 6
$CMTaskSequence = Get-CMTaskSequence -Name $ImageName

Start-CMTaskSequenceDeployment -CollectionName $ImageName -DeployPurpose Available `
-SendWakeUpPacket $False -UseMeteredNetWork $False -MakeAvailableTo Clients -RerunBehavior RerunIfFailedPreviousAttempt `
-ScheduleEvent AsSoonAsPossible -DeploymentOption DownloadAllContentLocallyBeforeStartingTaskSecuence `
AllowSharedContent $True -SystemRestart $true -TaskSequencePackageId $CMTaskSequence.PackageID


#---------------------------------------------------------------------------------------------------
# Create a Dynamic Collection.

Import-Module 'c:\program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.PSD1'
Set-Location PS1:\

#Adding a Schedule
$Schedule1 = New-CMSchedule -Start "01/01/2014 9:00 PM" -DayOfWeek Monday -RecurCount 1

#Create the collection
New-CMDeviceCollection -Name "QuickStart 1" -LimitingCollectionName "VM All Servers" -refreshSchedule $Schedule1 -RefreshType Periodic

#Add the dynamic collection query
Add-CMDeviceCollectionQueryMemberShipRule -CollectionName "Quickstart 1" -QueryExpression "Select * From SMS_R_System where SMS_R_System.SystemGroupName = 'ViaMonstra\\SUM_MW1' " -RuleName "QueryRuleName1"

#-------------------------------------------------------------------------------------------------------
