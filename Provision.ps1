<#Script to run from student VM, to build the Azure "on-premise" environment:

This script performs following tasks:
1. Create Azure affinity group, storage account, virtual network and basic settings
2. Copies VHDs from LeX Labs
3. Creates Virtual Machines (VM)

Usage:
Open elevated PowerShell
	1. CD E:\Setupfiles
	2. Set-ExecutionPolicy -scope Process Unrestricted -force
	3. . .\ConfigureStorageAndSettings.ps1

All scripts must be run from the same PowerShell session.
#>
Clear-Host
$starttime = Get-Date
#Obtain standard variables:
. .\Variables.ps1
. .\Functions.ps1
. .\suffix.ps1

# Need to add logic to find and load settings file

Write-Host "Script to create Azure environment for course 20346:" -ForegroundColor Magenta
Write-Host "Step 1. Generate unique student id" -ForegroundColor Magenta

#Obtain student's suffix used to generate a globally unique cloud service and storage name - student can leave rest of script to run unattended - CHANGED TO 8 DIGITS
If ($fullsuffix.length -lt 8){
	Do {
		Write-Host "What is the 8 digit number of your Learning Center (e.g. 87654321),"
		Write-Host "use following zeros if your number is less than 8 digit number "
		$lcnumber = read-host -prompt "(e.g. for 654321 enter 65432100)?"  
		If ($lcnumber.Length -ne 8) {
			Write-Host "You did not enter a 8 digit number - please check your Learning Center number" -ForegroundColor Red
			}
		} While ($lcnumber.Length -ne 8) #Make sure student enters a 8 digit number

	Do {
		Write-Host ""
		$stnumber = read-host -prompt "What is your 3 digit student number, including any leading zero (e.g. 009)" 
		If ($stnumber.Length -ne 3) {
			Write-Host "You did not enter a 3 digit number - please check your student number" -ForegroundColor Red
			}
		} While ($stnumber.Length -ne 3) #Make sure student enters a 3 digit number -  - CHANGED TO 3 DIGITS

	#Get a short date code to help make the DNS names completely unique
	$datestamp = Get-Date -format MMdd #Used to help generate unique Azure service names
	$fullsuffix = $lcnumber + $stnumber + $datestamp
	#Now store this for use in other scripts
	$suffixstring = '$fullsuffix = "' + $fullsuffix + '"'
	Add-Content -Encoding String -Path suffix.ps1 $suffixstring
}

Write-Host " "
Write-Host "Your unique suffix is: " $fullsuffix -ForegroundColor Green 
Write-Host " "
Write-Host "Step 2. Create Azure affinity group" -ForegroundColor Magenta
Write-Host " "

#Now start creating the Azure environment
$affinitygroupobj = Get-AzureAffinityGroup -Name $affinitygroup -ErrorAction SilentlyContinue
If ($affinitygroupobj){
	Write-Host "Affinity group" $affinitygroupobj.Name "already exists" -ForegroundColor Green
	If ($location.CompareTo($affinitygroupobj.Location) -ne 0){
		Write-Host "Affinity Group with same name exists in location " $affinitygroupobj.Location -ForeGroundColor Red
		Write-Host "Delete existing Affinity Group before proceeding"
		exit
	}
} Else {
	New-AzureAffinityGroup -Name $affinitygroup -Location $location
	# Wait while affinity group is created
	$affinitygroupobj = Get-AzureAffinityGroup -Name $affinitygroup
	Write-Host "Affinity group" $affinitygroupobj.Name "created" -ForegroundColor Green
}
Write-Host " "
Write-Host "Step 3. Create Azure storage service" -ForegroundColor Magenta
Write-Host " "

$storage = $storagebase + $fullsuffix
$storageobj = Get-AzureStorageAccount -StorageAccountName $storage -ErrorAction SilentlyContinue
If ($storageobj){
	Write-Host "Storage service" $storageobj.StorageAccountName "already exists." -ForegroundColor Green
	Write-Host "Using existing storage account." -ForegroundColor Green
} Else {
	New-AzureStorageAccount -StorageAccountName $storage -AffinityGroup $affinitygroup
	# Wait while storage is created
	$storageobj = Get-AzureStorageAccount -StorageAccountName $storage -ErrorAction SilentlyContinue
	If ($storageobj){
		Write-Host "Storage service" $storageobj.StorageAccountName "created" -ForegroundColor Green
		Write-Host " "
		Write-Host "Waiting for storage to provision ..." -ForegroundColor Magenta
		Start-Sleep -Seconds 30
	} Else {
		Write-Host "Create Storage Service Failed. Try running script this script again." -ForegroundColor Red
		Write-Host "If problem persists, please notify instructor." -ForegroundColor Red
	}
}
$subscriptionObj = get-AzureSubscription -Default
$subscriptionName = $subscriptionObj.SubscriptionName
set-azuresubscription -SubscriptionName $subscriptionName -CurrentStorageAccountName $storage
select-azuresubscription -SubscriptionName $subscriptionName

Write-Host " "
Write-Host "Step 4. Create Virtual Network" -ForegroundColor Magenta
Write-Host " "
#============================================== Configure DNS
$dns = New-AzureDns -IPAddress 10.0.0.4 -Name $dnsname
Set-AzureVNetConfig -ConfigurationPath $netconfigpath 
#ADDED - Need to make sure that the previous steps have completed before next steps:
Write-Host "Waiting for network to provision ..." -ForegroundColor Magenta
Start-Sleep -Seconds 60
Write-Host " "
Write-Host "Network and DNS configured" -ForegroundColor Green
Write-Host " "

Write-Host " "
Write-Host "Step 5A. Copy VHD Blobs" -ForegroundColor Magenta
Write-Host " "

$destStorageAccountKeyObj = get-azurestoragekey $storage
$destStorageAccountKey = $destStorageAccountKeyObj.Primary
$dest = New-AzureStorageContext $storage $destStorageAccountKey
$storageContainerobj = Get-AzureStorageContainer $destStorageContainer -context $dest -ErrorAction SilentlyContinue
If ($storageContainerobj){
	Write-Host "Storage container" $destStorageContainer "already exists." -ForegroundColor Green
	Write-Host "Validating Storage Container" -ForegroundColor Magenta
	
	Write-Host "Using existing storage container." -ForegroundColor Green
} Else {
	New-AzureStorageContainer $destStorageContainer -Permission Container -context $dest
}

$blobsExist = Get-AzureStorageBlob -Context $dest -Container $destStorageContainer -ErrorAction SilentlyContinue | where {$_.Name -like "*vhd"} 
If ($blobsExist)
{
	switch ($blobsExist.count)
    {
        0 
			{
				Write-Host "No VHDs found" -ForegroundColor Magenta
				CopyAllVHDBlobs $dest $destStorageContainer 
			}
        9 
			{
				Write-Host "All 9 VHDs exist in your storage container" -Foregroundcolor Magenta
				Write-Host "Validating Storage Container" -ForegroundColor Magenta
			}
		default 
			{
				Write-Host "Incomplete $blobExist.count out 9 blobs"
				Foreach ($vhdname in $vhdlist) {
					$blobname = $vhdname + "-0.vhd" 
					$blobExist = Get-AzureStorageBlob -Container $destStorageContainer -blob $vhdname -ErrorAction SilentlyContinue
					If($blobExist) {
						Write-Host "Blob for VHD $blobname exists"
					} Else { 
						CopyOneVHDBlob $dest $destStorageContainer $blobname 
					}
					If($vhdname -eq "LUC-EX1") {
						$blobname = $vhdname + "-1.vhd" 
						$blobExist = Get-AzureStorageBlob -Container $destStorageContainer -blob $vhdname -ErrorAction SilentlyContinue
						If($blobExist) {
							Write-Host "Blob for VHD $blobname exists"
						} Else { 
							CopyOneVHDBlob $dest $destStorageContainer $blobname 
						}
						$blobname = $vhdname + "-2.vhd" 
						$blobExist = Get-AzureStorageBlob -Container $destStorageContainer -blob $vhdname -ErrorAction SilentlyContinue
						If($blobExist) {
							Write-Host "Blob for VHD $blobname exists"
						} Else { 
							CopyOneVHDBlob $dest $destStorageContainer $blobname 
						}
				}	
			}
    }
} } Else {
	Write-Host "No VHD" -ForegroundColor Magenta
	CopyAllVHDBlobs $dest $destStorageContainer 
}
$blobsExist = Get-AzureStorageBlob -Context $dest -Container $destStorageContainer # -ErrorAction SilentlyContinue | where {$_.Name -like "*vhd"}

$delaySeconds = 60
    do
    {
        Write-Verbose "Checking storage blob copy status every $delaySeconds seconds."
        Write-Verbose "This will repeat until all copy operations are complete."
        Write-Verbose "Press Ctrl-C anytime to stop checking status."
        
        $continue = $false
        $blobsExist | Get-AzureStorageBlobCopyState| Format-Table -AutoSize -Property Status,@{label="Percent";expression={"{0:P2}" -f $($_.BytesCopied/$_.TotalBytes)}}, @{label="VHD";expression={$($_.Source).tostring().substring(44,13)}}
        
        foreach ($copyState in $blobsExist)
        {
            # Check the copy state for each blob.
            $copyStatus = $copyState | Get-AzureStorageBlobCopyState
 
            # Continue checking status as long as at least one operations is still pending.
            if (!$continue)
            {
                $continue = $copyStatus.Status -eq "Pending"
            }
            
        }

        if ($continue)
        {
            Start-Sleep $delaySeconds
        }
    } while ($continue)
 
If ($blobsExist.count -eq 9) {
	Write-Host " "
	Write-Host "All 9 VHD blobs defined and copy started." -ForegroundColor Green
	Write-Host " " 
	Write-Host "Step 5B. Define Virtual Disks" -ForegroundColor Magenta
	Write-Host " "

	$blobsToDisks = Get-AzureStorageBlob -Context $dest -Container $destStorageContainer | where {$_.Name -like "*0.vhd"}
	foreach($currentOSDisk in $blobsToDisks){
		$diskName = $currentOSDisk.Name.Substring(0,7)
		Add-AzureDisk -DiskName $diskName -MediaLocation $currentOSDisk.ICloudBlob.Uri -OS Windows #-ErrorAction SilentlyContinue
	}

	$blobsToDisks = Get-AzureStorageBlob -Context $dest -Container $destStorageContainer | where {$_.Name -like "*1.vhd"}
	foreach($currentDisk in $blobsToDisks){
		$diskName = $currentDisk.Name.Substring(0,9)
		Add-AzureDisk -DiskName $diskName -MediaLocation $currentDisk.ICloudBlob.Uri -Label ExDB #-ErrorAction SilentlyContinue
	}

	$blobsToDisks = Get-AzureStorageBlob -Context $dest -Container $destStorageContainer | where {$_.Name -like "*2.vhd"}
	foreach($currentDisk in $blobsToDisks){
		$diskName = $currentDisk.Name.Substring(0,9)
		Add-AzureDisk -DiskName $diskName -MediaLocation $currentDisk.ICloudBlob.Uri -Label ExLogs #-ErrorAction SilentlyContinue
	}
	
	if ((get-azuredisk).count -eq (Get-AzureStorageBlob -Context $dest -Container $destStorageContainer).count) {
		Write-Host " "
		Write-Host "Virtual Disks defined for all VHD blobs." -Foregroundcolor Green
		Write-Host " "
	} else {
		Write-Host "There is an inconsistency with the Virtual Hard Disks" -Foregroundcolor Red
	}

} Else {
	Write-Host "There is an inconsistency with the VHD blobs" -Foregroundcolor Red
	Exit
}

	
Write-Host " "
Write-Host "Step 6 Creating VMs" -ForegroundColor Magenta
Write-Host " "
$cloudservice = $cloudservicebase + $fullsuffix

Write-Host "Creating LUC-DC1" -ForegroundColor Magenta
Write-Host " "
$vmName = $dc1
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-DC1" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
			Add-AzureProvisioningConfig -Windows | 
			Add-AzureEndpoint -Name "DNS" -Protocol tcp -LocalPort 53 -PublicPort 53 | 
			Add-AzureEndpoint -Name "DNS-UDP" -Protocol udp -LocalPort 53 -PublicPort 53 | 
			Set-AzureSubnet -SubnetNames $subnet | 
			Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $true $affinitygroup $vnet $dns
}

Write-Host "Creating LUC-EX1" -ForegroundColor Magenta
Write-Host " "
$vmName = $ex1
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-EX1" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Medium' | 
			Add-AzureProvisioningConfig -Windows | 
			Add-AzureDataDisk -Import 'LUC-EX1-1' -LUN 0 | 
			Add-AzureDataDisk -Import 'LUC-EX1-2' -LUN 1 | 
			Add-AzureEndpoint -Name 'smtp' -LocalPort 25 -PublicPort 25 -Protocol tcp | 
			Add-AzureEndpoint -Name 'http' -LocalPort 80 -PublicPort 80 -Protocol tcp | 
			Add-AzureEndpoint -Name 'https' -LocalPort 443 -PublicPort 443 -Protocol tcp | 
			Add-AzureEndpoint -Name 'imap' -LocalPort 993 -PublicPort 993 -Protocol tcp |  
			Set-AzureSubnet -SubnetNames $subnet | 
			Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
}

Write-Host "Creating LUC-SV1" -ForegroundColor Magenta
Write-Host " "
$vmName = $svr1
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-SV1" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
			Add-AzureProvisioningConfig -Windows |  
			Set-AzureSubnet -SubnetNames $subnet | 
			Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
}

Write-Host "Creating LUC-SV2" -ForegroundColor Magenta
Write-Host " "
$vmName = $svr2
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-SV2" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
			Add-AzureProvisioningConfig -Windows | 
			Set-AzureSubnet -SubnetNames $subnet | 
			Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
} 

Write-Host "Creating LUC-SV3" -ForegroundColor Magenta
Write-Host " "
$vmName = $svr3
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-SV3" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
			Add-AzureProvisioningConfig -Windows | 
			Set-AzureSubnet -SubnetNames $subnet | 
			Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
}

Write-Host "Creating LUC-CL2" -ForegroundColor Magenta
Write-Host " "
$vmName = $cl2
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-CL2" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
		Add-AzureProvisioningConfig -Windows | 
		Set-AzureSubnet -SubnetNames $subnet | 
		Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
} 

Write-Host "Creating LUC-CL3" -ForegroundColor Magenta
Write-Host " "
$vmName = $cl3
$existingVMobj = get-azurevm $cloudservice -Name $vmName -ErrorAction SilentlyContinue
if ($existingVMobj){
	Write-Host "Keeping existing LUC-CL3" -ForegroundColor Magenta
	Write-Host " "
} Else {
	$newVM = New-AzureVMConfig -Name $vmName -DiskName $vmName -InstanceSize 'Small' | 
		Add-AzureProvisioningConfig -Windows | 
		Set-AzureSubnet -SubnetNames $subnet | 
		Set-AzureVMBGInfoExtension -ReferenceName 'BGInfo'
	CreateVM $newVM $vmname $cloudservice $false $affinitygroup $vnet $dns
}

Get-AzureVM | % { Get-AzureRemoteDesktopFile -ServiceName $cloudservice -Name $_.Name -LocalPath $($RDPfilesdir+$_.Name+".rdp") }

#Reset default verbose level variable:
$VerbosePreference = 'SilentlyContinue'

#Write a status messages:
Write-Host "Azure Environment Created" -ForegroundColor Magenta
Write-Host " "
$endtime = Get-Date
Write-Host Started at $starttime -ForegroundColor Magenta
Write-Host Ended at $endtime -ForegroundColor Magenta
$elapsed = $endtime - $starttime

If ($elapsed.Hours -ne 0){
  Write-Host Total elapsed time is $elapsed.Hours hours $elapsed.Minutes minutes -ForegroundColor Magenta
} Else {
  Write-Host Total elapsed time is $elapsed.Minutes minutes -ForegroundColor Magenta
}
Write-Host " "
Write-Host "============================================================================================== " -ForegroundColor Green
Write-Host " "

Get-AzureStorageAccount | Format-Table -Property Label,AffinityGroup,GeoPrimaryLocation
Write-Host " "
Write-Host "Your datacenter location is: " $location -ForegroundColor Green
Write-Host "Your unique suffix is: " $fullsuffix -ForegroundColor Green 

#Reset verbose level variable:
$VerbosePreference = "Continue"	

# SIG # Begin signature block
# MIIatQYJKoZIhvcNAQcCoIIapjCCGqICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUu0np4oLocOWLXivfXU8gdjdj
# HQKgghV6MIIEuzCCA6OgAwIBAgITMwAAAFnWc81RjvAixQAAAAAAWTANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTQwNTIzMTcxMzE1
# WhcNMTUwODIzMTcxMzE1WjCBqzELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# DTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpGNTI4LTM3
# NzctOEE3NjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMZsTs9oU/3vgN7oi8Sx8H4H
# zh487AyMNYdM6VE6vLawlndC+v88z+Ha4on6bkIAmVsW3QlkOOJS+9+O+pOjPbuH
# j264h8nQYE/PnIKRbZEbchCz2EN8WUpgXcawVdAn2/L2vfIgxiIsnmuLLWzqeATJ
# S8FwCee2Ha+ajAY/eHD6du7SJBR2sq4gKIMcqfBIkj+ihfeDysVR0JUgA3nSV7wT
# tU64tGxWH1MeFbvPMD/9OwHNX3Jo98rzmWYzqF0ijx1uytpl0iscJKyffKkQioXi
# bS5cSv1JuXtAsVPG30e5syNOIkcc08G5SXZCcs6Qhg4k9cI8uQk2P6hTXFb+X2EC
# AwEAAaOCAQkwggEFMB0GA1UdDgQWBBRbKBqzzXUNYz39mfWbFQJIGsumrDAfBgNV
# HSMEGDAWgBQjNPjZUkZwCu1A+3b7syuwwzWzDzBUBgNVHR8ETTBLMEmgR6BFhkNo
# dHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNyb3Nv
# ZnRUaW1lU3RhbXBQQ0EuY3JsMFgGCCsGAQUFBwEBBEwwSjBIBggrBgEFBQcwAoY8
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNyb3NvZnRUaW1l
# U3RhbXBQQ0EuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBBQUA
# A4IBAQB68A30RWw0lg538OLAQgVh94jTev2I1af193/yCPbV/cvKdHzbCanf1hUH
# mb/QPoeEYnvCBo7Ki2jiPd+eWsWMsqlc/lliJvXX+Xi2brQKkGVm6VEI8XzJo7cE
# N0bF54I+KFzvT3Gk57ElWuVDVDMIf6SwVS3RgnBIESANJoEO7wYldKuFw8OM4hRf
# 6AVUj7qGiaqWrpRiJfmvaYgKDLFRxAnvuIB8U5B5u+mP0EjwYsiZ8WU0O/fOtftm
# mLmiWZldPpWfFL81tPuYciQpDPO6BHqCOftGzfHgsha8fSD4nDkVJaEmLdaLgb3G
# vbCdVP5HC18tTir0h+q1D7W37ZIpMIIE7DCCA9SgAwIBAgITMwAAAMps1TISNcTh
# VQABAAAAyjANBgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTAeFw0xNDA0MjIxNzM5MDBaFw0xNTA3MjIxNzM5MDBaMIGDMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQ0wCwYDVQQLEwRNT1BSMR4wHAYDVQQD
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCWcV3tBkb6hMudW7dGx7DhtBE5A62xFXNgnOuntm4aPD//ZeM08aal
# IV5WmWxY5JKhClzC09xSLwxlmiBhQFMxnGyPIX26+f4TUFJglTpbuVildGFBqZTg
# rSZOTKGXcEknXnxnyk8ecYRGvB1LtuIPxcYnyQfmegqlFwAZTHBFOC2BtFCqxWfR
# +nm8xcyhcpv0JTSY+FTfEjk4Ei+ka6Wafsdi0dzP7T00+LnfNTC67HkyqeGprFVN
# TH9MVsMTC3bxB/nMR6z7iNVSpR4o+j0tz8+EmIZxZRHPhckJRIbhb+ex/KxARKWp
# iyM/gkmd1ZZZUBNZGHP/QwytK9R/MEBnAgMBAAGjggFgMIIBXDATBgNVHSUEDDAK
# BggrBgEFBQcDAzAdBgNVHQ4EFgQUH17iXVCNVoa+SjzPBOinh7XLv4MwUQYDVR0R
# BEowSKRGMEQxDTALBgNVBAsTBE1PUFIxMzAxBgNVBAUTKjMxNTk1K2I0MjE4ZjEz
# LTZmY2EtNDkwZi05YzQ3LTNmYzU1N2RmYzQ0MDAfBgNVHSMEGDAWgBTLEejK0rQW
# WAHJNy4zFha5TJoKHzBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNDb2RTaWdQQ0FfMDgtMzEtMjAx
# MC5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY0NvZFNpZ1BDQV8wOC0zMS0yMDEwLmNy
# dDANBgkqhkiG9w0BAQUFAAOCAQEAd1zr15E9zb17g9mFqbBDnXN8F8kP7Tbbx7Us
# G177VAU6g3FAgQmit3EmXtZ9tmw7yapfXQMYKh0nfgfpxWUftc8Nt1THKDhaiOd7
# wRm2VjK64szLk9uvbg9dRPXUsO8b1U7Brw7vIJvy4f4nXejF/2H2GdIoCiKd381w
# gp4YctgjzHosQ+7/6sDg5h2qnpczAFJvB7jTiGzepAY1p8JThmURdwmPNVm52Iao
# AP74MX0s9IwFncDB1XdybOlNWSaD8cKyiFeTNQB8UCu8Wfz+HCk4gtPeUpdFKRhO
# lludul8bo/EnUOoHlehtNA04V9w3KDWVOjic1O1qhV0OIhFeezCCBbwwggOkoAMC
# AQICCmEzJhoAAAAAADEwDQYJKoZIhvcNAQEFBQAwXzETMBEGCgmSJomT8ixkARkW
# A2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9z
# b2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTEwMDgzMTIyMTkzMloX
# DTIwMDgzMTIyMjkzMloweTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCycllcGTBkvx2aYCAgQpl2U2w+G9Zv
# zMvx6mv+lxYQ4N86dIMaty+gMuz/3sJCTiPVcgDbNVcKicquIEn08GisTUuNpb15
# S3GbRwfa/SXfnXWIz6pzRH/XgdvzvfI2pMlcRdyvrT3gKGiXGqelcnNW8ReU5P01
# lHKg1nZfHndFg4U4FtBzWwW6Z1KNpbJpL9oZC/6SdCnidi9U3RQwWfjSjWL9y8lf
# RjFQuScT5EAwz3IpECgixzdOPaAyPZDNoTgGhVxOVoIoKgUyt0vXT2Pn0i1i8UU9
# 56wIAPZGoZ7RW4wmU+h6qkryRs83PDietHdcpReejcsRj1Y8wawJXwPTAgMBAAGj
# ggFeMIIBWjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTLEejK0rQWWAHJNy4z
# Fha5TJoKHzALBgNVHQ8EBAMCAYYwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEE
# AYI3FQIEFgQU/dExTtMmipXhmGA7qDFvpjy82C0wGQYJKwYBBAGCNxQCBAweCgBT
# AHUAYgBDAEEwHwYDVR0jBBgwFoAUDqyCYEBWJ5flJRP8KuEKU5VZ5KQwUAYDVR0f
# BEkwRzBFoEOgQYY/aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJv
# ZHVjdHMvbWljcm9zb2Z0cm9vdGNlcnQuY3JsMFQGCCsGAQUFBwEBBEgwRjBEBggr
# BgEFBQcwAoY4aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNy
# b3NvZnRSb290Q2VydC5jcnQwDQYJKoZIhvcNAQEFBQADggIBAFk5Pn8mRq/rb0Cx
# MrVq6w4vbqhJ9+tfde1MOy3XQ60L/svpLTGjI8x8UJiAIV2sPS9MuqKoVpzjcLu4
# tPh5tUly9z7qQX/K4QwXaculnCAt+gtQxFbNLeNK0rxw56gNogOlVuC4iktX8pVC
# nPHz7+7jhh80PLhWmvBTI4UqpIIck+KUBx3y4k74jKHK6BOlkU7IG9KPcpUqcW2b
# Gvgc8FPWZ8wi/1wdzaKMvSeyeWNWRKJRzfnpo1hW3ZsCRUQvX/TartSCMm78pJUT
# 5Otp56miLL7IKxAOZY6Z2/Wi+hImCWU4lPF6H0q70eFW6NB4lhhcyTUWX92THUmO
# Lb6tNEQc7hAVGgBd3TVbIc6YxwnuhQ6MT20OE049fClInHLR82zKwexwo1eSV32U
# jaAbSANa98+jZwp0pTbtLS8XyOZyNxL0b7E8Z4L5UrKNMxZlHg6K3RDeZPRvzkbU
# 0xfpecQEtNP7LN8fip6sCvsTJ0Ct5PnhqX9GuwdgR2VgQE6wQuxO7bN2edgKNAlt
# HIAxH+IOVN3lofvlRxCtZJj/UBYufL8FIXrilUEnacOTj5XJjdibIa4NXJzwoq6G
# aIMMai27dmsAHZat8hZ79haDJLmIz2qoRzEvmtzjcT3XAH5iR9HOiMm4GPoOco3B
# oz2vAkBq/2mbluIQqBC0N1AI1sM9MIIGBzCCA++gAwIBAgIKYRZoNAAAAAAAHDAN
# BgkqhkiG9w0BAQUFADBfMRMwEQYKCZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPy
# LGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZp
# Y2F0ZSBBdXRob3JpdHkwHhcNMDcwNDAzMTI1MzA5WhcNMjEwNDAzMTMwMzA5WjB3
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhN
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCfoWyx39tIkip8ay4Z4b3i48WZUSNQrc7dGE4kD+7Rp9FMrXQwIBHr
# B9VUlRVJlBtCkq6YXDAm2gBr6Hu97IkHD/cOBJjwicwfyzMkh53y9GccLPx754gd
# 6udOo6HBI1PKjfpFzwnQXq/QsEIEovmmbJNn1yjcRlOwhtDlKEYuJ6yGT1VSDOQD
# LPtqkJAwbofzWTCd+n7Wl7PoIZd++NIT8wi3U21StEWQn0gASkdmEScpZqiX5NMG
# gUqi+YSnEUcUCYKfhO1VeP4Bmh1QCIUAEDBG7bfeI0a7xC1Un68eeEExd8yb3zuD
# k6FhArUdDbH895uyAc4iS1T/+QXDwiALAgMBAAGjggGrMIIBpzAPBgNVHRMBAf8E
# BTADAQH/MB0GA1UdDgQWBBQjNPjZUkZwCu1A+3b7syuwwzWzDzALBgNVHQ8EBAMC
# AYYwEAYJKwYBBAGCNxUBBAMCAQAwgZgGA1UdIwSBkDCBjYAUDqyCYEBWJ5flJRP8
# KuEKU5VZ5KShY6RhMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/Is
# ZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eYIQea0WoUqgpa1Mc1j0BxMuZTBQBgNVHR8ESTBHMEWgQ6BB
# hj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9taWNy
# b3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEESDBGMEQGCCsGAQUFBzAChjho
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29mdFJvb3RD
# ZXJ0LmNydDATBgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQUFAAOCAgEA
# EJeKw1wDRDbd6bStd9vOeVFNAbEudHFbbQwTq86+e4+4LtQSooxtYrhXAstOIBNQ
# md16QOJXu69YmhzhHQGGrLt48ovQ7DsB7uK+jwoFyI1I4vBTFd1Pq5Lk541q1YDB
# 5pTyBi+FA+mRKiQicPv2/OR4mS4N9wficLwYTp2OawpylbihOZxnLcVRDupiXD8W
# mIsgP+IHGjL5zDFKdjE9K3ILyOpwPf+FChPfwgphjvDXuBfrTot/xTUrXqO/67x9
# C0J71FNyIe4wyrt4ZVxbARcKFA7S2hSY9Ty5ZlizLS/n+YWGzFFW6J1wlGysOUzU
# 9nm/qhh6YinvopspNAZ3GmLJPR5tH4LwC8csu89Ds+X57H2146SodDW4TsVxIxIm
# dgs8UoxxWkZDFLyzs7BNZ8ifQv+AeSGAnhUwZuhCEl4ayJ4iIdBD6Svpu/RIzCzU
# 2DKATCYqSCRfWupW76bemZ3KOm+9gSd0BhHudiG/m4LBJ1S2sWo9iaF2YbRuoROm
# v6pH8BJv/YoybLL+31HIjCPJZr2dHYcSZAI9La9Zj7jkIeW1sMpjtHhUBdRBLlCs
# lLCleKuzoJZ1GtmShxN1Ii8yqAhuoFuMJb+g74TKIdbrHk/Jmu5J4PcBZW+JC33I
# acjmbuqnl84xKf8OxVtc2E0bodj6L54/LlUWa8kTo/0xggSlMIIEoQIBATCBkDB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQQITMwAAAMps1TISNcThVQABAAAAyjAJ
# BgUrDgMCGgUAoIG+MBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQBS1IhsJY49zy1
# gTtP5zfuldWhmjBeBgorBgEEAYI3AgEMMVAwTqAmgCQATQBpAGMAcgBvAHMAbwBm
# AHQAIABMAGUAYQByAG4AaQBuAGehJIAiaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L2xlYXJuaW5nIDANBgkqhkiG9w0BAQEFAASCAQAoUhSTrCEPyuA4p+EweEzCPwkY
# v7dR7U8SBJMyGpVWXRPHEGQn1mnSxUpprathcisoC/AiXoErp0V9aZmbtIAhMYTM
# oHJ3DlQWrx+J56SSS95OI8ttdtMjrmD0Zy1+k2EkaMidESXizZeF20oZbIbAdLao
# F8MJ4AtcTBIK2s7Oy55wioXNI9CjDpxMObUp1PQYVq2DoKiKYhrgxsK2EmA7ITxR
# lD2RbiNIqtdtZrKkNjcwzzL0aCsocR96+r+x3UCZtb7FqhtjJf4QVdY68BaaiUxX
# qcBAvn5AIiIKMTBFTvGY5sCULksucE/o3ssuyFizqOoRf1oDBk5lNZyqKQ/9oYIC
# KDCCAiQGCSqGSIb3DQEJBjGCAhUwggIRAgEBMIGOMHcxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQQITMwAAAFnWc81RjvAixQAAAAAAWTAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwMTA3MTU1NjI4
# WjAjBgkqhkiG9w0BCQQxFgQUTBXJGZ6bbvWLKL3HiJEusFTiI+8wDQYJKoZIhvcN
# AQEFBQAEggEAec4FZ7ObH3TnltNooPDxvfk/2/2RxXsqbSjMBLg7qtRzL+gZuwX9
# B8JewrTSfxRN2VjnK9Alp2km31+8DQtPORoeZaGuSeJ35kqnDoX3J41T1MI8FoSG
# ep+wvjhUj5O5hu2Lkl0cs/cUdpjIkYdhJMsH4gfmQI7K/1vr5R9xtmb/FQCtoRlg
# jsbptGcj0rPXyXHwTq/U+N0S5b+2e05p6sGEhAGNWT/Kcc159QsF/plAmmgu32dp
# gKTQPA+JC2wunmkOoCuEhKlpSFOfm3BcneFtWgSZJsCcBkbm0ou2xdb3U8LG560m
# x6B0qFd3MSXdV/LAh8ApJPcklgbhJv4p7Q==
# SIG # End signature block
