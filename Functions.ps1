$VerbosePreference = "Continue"Function CreateVM(){  param (    [Parameter(Mandatory=$true)]$vmconfig,     [Parameter(Mandatory=$true)]$vmname,     [Parameter(Mandatory=$true)]$cloudservice,     [Parameter(Mandatory=$true)]$isDC,     [Parameter(Mandatory=$false)]$affinitygroup,     [Parameter(Mandatory=$false)]$vnet,     [Parameter(Mandatory=$false)]$dns  )  Write-Verbose "Creating VM: $vmname"   #Create the VM, and sets up the deployment to the cloud service  $created = $false  While (!$created)  {    Try    {      # This may fail if other resources are locked      if ($isDC -eq $true)      {        New-AzureVM -ServiceName $cloudservice -AffinityGroup $affinitygroup -VMs $vmconfig -VNetName $vnet -DnsSettings $dns -WaitForBoot      } else {        New-AzureVM -ServiceName $cloudservice -VMs $vmconfig -WaitForBoot      }      $created = $true      #Write a status message:      Write-Verbose " "      Write-Verbose "$vmname created"    }    Catch    {      # Sleep for 30 seconds before retrying      Start-Sleep -Seconds 30    }  }      #Wait for provisioning to complete ...  Start-Sleep -Seconds 60  $VMStatus = Get-AzureVM -ServiceName $cloudservice -Name $vmname  While ($VMStatus.InstanceStatus -ne "ReadyRole")
  {
    Write-Verbose "Waiting for $vmname to become ready ..."
    Start-Sleep -Seconds 60
    $VMStatus = Get-AzureVM -ServiceName $cloudservice -Name $vmname
  }}Function RestartVM($cloudservice, $vmname){  Restart-AzureVM -ServiceName $cloudservice -Name $vmname
  $VMStatus = Get-AzureVM -ServiceName $cloudservice -Name $vmname  While ($VMStatus.InstanceStatus -ne "ReadyRole")
  {
    Write-Verbose " "
    Write-Verbose "Waiting for $vmname to restart ..."
    Start-Sleep -Seconds 15
    $VMStatus = Get-AzureVM -ServiceName $cloudservice -Name $vmname
  }  # Wait for an additional minute to allow the VM to stabilize  Start-Sleep -Seconds (60)}Function InstallWinRMCertificateForVM ($servicename, $svrname){    Write-Verbose "Installing WinRM Certificate for remote access: $servicename $svrname"
    $WinRMCert = (Get-AzureVM -ServiceName $servicename -Name $svrname | select -ExpandProperty vm).DefaultWinRMCertificateThumbprint
	$AzureX509cert = Get-AzureCertificate -ServiceName $servicename -Thumbprint $WinRMCert -ThumbprintAlgorithm sha1

	$certTempFile = [IO.Path]::GetTempFileName()
	$AzureX509cert.Data | Out-File $certTempFile

	# Target The Cert That Needs To Be Imported
	$CertToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certTempFile

	$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
	$store.Open("ReadWrite")
	$store.Add($CertToImport)
	$store.Close()
	
	Remove-Item $certTempFile
}
Function CopyAllVHDBlobs ($dest, $destStorageContainer ) {	$starttime = Get-Date    $copiedBlobs = @()	$copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-DC1-0.vhd" -DestBlob "LUC-DC1-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-EX1-0.vhd" -DestBlob "LUC-EX1-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-EX1-1.vhd" -DestBlob "LUC-EX1-1.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-EX1-2.vhd" -DestBlob "LUC-EX1-2.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-SV1-0.vhd" -DestBlob "LUC-SV1-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-SV2-0.vhd" -DestBlob "LUC-SV2-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-SV3-0.vhd" -DestBlob "LUC-SV3-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-CL2-0.vhd" -DestBlob "LUC-CL2-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force    $copiedBlobs += Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/LUC-CL3-0.vhd" -DestBlob "LUC-CL3-0.vhd" -DestContext $dest -DestContainer $destStorageContainer -force	$copiedBlobs | Get-AzureStorageBlobCopyState	    $delaySeconds = 60
    do
    {
        Write-Verbose "Checking storage blob copy status every $delaySeconds seconds."
        Write-Verbose "This will repeat until all copy operations are complete."
        Write-Verbose "Press Ctrl-C anytime to stop checking status."
        Start-Sleep $delaySeconds

        $continue = $false
        $copiedBlobs | Get-AzureStorageBlobCopyState| Format-Table -AutoSize -Property Status,@{label="Percent";expression={"{0:P2}" -f $($_.BytesCopied/$_.TotalBytes)}}, @{label="VHD";expression={$($_.Source).tostring().substring(44,13)}}

        foreach ($copyState in $copiedBlobs)
        {
            # Check the copy state for each blob.
            $copyStatus = $copyState | Get-AzureStorageBlobCopyState
 
            # Continue checking status as long as at least one operations is still pending.
            if (!$continue)
            {
                $continue = $copyStatus.Status -eq "Pending"
            }
        }
    } while ($continue)
    	$endtime = Get-Date	Write-Host "VHD blob copy started at $starttime" -ForegroundColor Magenta	Write-Host "VHD blob copy ended at $endtime" -ForegroundColor Magenta	$elapsed = $endtime - $starttime	If ($elapsed.Hours -ne 0){	    Write-Host Total elapsed time is $elapsed.Hours hours $elapsed.Minutes minutes -ForegroundColor Magenta	} Else {	    Write-Host Total elapsed time is $elapsed.Minutes minutes -ForegroundColor Magenta	}	Write-Host " "	Write-Host "============================================================================================== " -ForegroundColor Green	Write-Host " "}Function CopyOneVHDBlob ($dest, $destStorageContainer, $blobname ) {	$copiedBlobs = Start-AzureStorageBlobCopy -AbsoluteUri "https://lex20346.blob.core.windows.net/vhds/$blobname" -DestBlob $blobname -DestContext $dest -DestContainer $destStorageContainer -force	$copiedBlobs | Get-AzureStorageBlobCopyState    $delaySeconds = 60
    do
    {
        Write-Verbose "Checking storage blob copy status every $delaySeconds seconds."
        Write-Verbose "This will repeat until all copy operations are complete."
        Write-Verbose "Press Ctrl-C anytime to stop checking status."
        Start-Sleep $delaySeconds

        $continue = $false
        $copiedBlobs | Get-AzureStorageBlobCopyState| Format-Table -AutoSize -Property Status,@{label="Percent";expression={"{0:P2}" -f $($_.BytesCopied/$_.TotalBytes)}},@{label="VHD";expression={$($_.Source).tostring().substring(44,13)}}

        foreach ($copyState in $copiedBlobs)
        {
            # Check the copy state for each blob.
            $copyStatus = $copyState | Get-AzureStorageBlobCopyState
 
            # Continue checking status as long as at least one operations is still pending.
            if (!$continue)
            {
                $continue = $copyStatus.Status -eq "Pending"
            }
        }
    } while ($continue)}
# SIG # Begin signature block
# MIIatQYJKoZIhvcNAQcCoIIapjCCGqICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSH70HAtFB2Gn/L6btXe88G/3
# dAagghV6MIIEuzCCA6OgAwIBAgITMwAAAFrtL/TkIJk/OgAAAAAAWjANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTQwNTIzMTcxMzE1
# WhcNMTUwODIzMTcxMzE1WjCBqzELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAldBMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# DTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMw
# QTQtNzE0NDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALMhIt9q0L/7KcnVbHqJqY0T
# vJS16X0pZdp/9B+rDHlhZlRhlgfw1GBLMZsJr30obdCle4dfdqHSxinHljqjXxeM
# duC3lgcPx2JhtLaq9kYUKQMuJrAdSgjgfdNcMBKmm/a5Dj1TFmmdu2UnQsHoMjUO
# 9yn/3lsgTLsvaIQkD6uRxPPOKl5YRu2pRbRptlQmkRJi/W8O5M/53D/aKWkfSq7u
# wIJC64Jz6VFTEb/dqx1vsgpQeAuD7xsIsxtnb9MFfaEJn8J3iKCjWMFP/2fz3uzH
# 9TPcikUOlkYUKIccYLf1qlpATHC1acBGyNTo4sWQ3gtlNdRUgNLpnSBWr9TfzbkC
# AwEAAaOCAQkwggEFMB0GA1UdDgQWBBS+Z+AuAhuvCnINOh1/jJ1rImYR9zAfBgNV
# HSMEGDAWgBQjNPjZUkZwCu1A+3b7syuwwzWzDzBUBgNVHR8ETTBLMEmgR6BFhkNo
# dHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNyb3Nv
# ZnRUaW1lU3RhbXBQQ0EuY3JsMFgGCCsGAQUFBwEBBEwwSjBIBggrBgEFBQcwAoY8
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNyb3NvZnRUaW1l
# U3RhbXBQQ0EuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBBQUA
# A4IBAQAgU4KQrqZNTn4zScizrcTDfhXQEvIPJ4p/W78+VOpB6VQDKym63VSIu7n3
# 2c5T7RAWPclGcLQA0fI0XaejIiyqIuFrob8PDYfQHgIb73i2iSDQLKsLdDguphD/
# 2pGrLEA8JhWqrN7Cz0qTA81r4qSymRpdR0Tx3IIf5ki0pmmZwS7phyPqCNJp5mLf
# cfHrI78hZfmkV8STLdsWeBWqPqLkhfwXvsBPFduq8Ki6ESus+is1Fm5bc/4w0Pur
# k6DezULaNj+R9+A3jNkHrTsnu/9UIHfG/RHpGuZpsjMnqwWuWI+mqX9dEhFoDCyj
# MRYNviGrnPCuGnxA1daDFhXYKPvlMIIE7DCCA9SgAwIBAgITMwAAAMps1TISNcTh
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRjrKleYyIjMFsN
# RvnGfaQBqenvwTBeBgorBgEEAYI3AgEMMVAwTqAmgCQATQBpAGMAcgBvAHMAbwBm
# AHQAIABMAGUAYQByAG4AaQBuAGehJIAiaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L2xlYXJuaW5nIDANBgkqhkiG9w0BAQEFAASCAQCLM7lDwmEbPzNaN597CMU7B39H
# pJXRcw8zSpitTEll2Sfe1CmlkMrdSJBW11b2cHpcbvnZXZjglse2JaEqSeplBFl0
# UKP/Lus8QcV5MLQSloEZG0A2NZMIo0FbheL0cpUYdDcT3J6t9el4G4WA4Ig8vrcU
# pYZ5IKVm+6hJzKkD39a6zhshlmAoyEhOlrLks73abLzMD0/NEupoQIMWbvaQMbhX
# ExWlylufxHTMkyk7lzyMLQy89IqFbU9pU5YFCX0u5H47QU52RI3BVUiiqruLwxlU
# 7vMXEIKTR8GLv+k3CjM0HulUZgv/E6CU0watr0Kpg7UxqCjZR4dWgZatpq9voYIC
# KDCCAiQGCSqGSIb3DQEJBjGCAhUwggIRAgEBMIGOMHcxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQQITMwAAAFrtL/TkIJk/OgAAAAAAWjAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwMzE3MTU1MTM0
# WjAjBgkqhkiG9w0BCQQxFgQUY/+vih1WC6fSjpcGvthr4mw4bN4wDQYJKoZIhvcN
# AQEFBQAEggEAhwygBcl3ML+7nOnwjct2o2N06hqy63KbNtWv50dbZZ/SIkw3x7ky
# Ru1JVn09bVn6RJYAEpyhJfCUy924kExLrD5AYszI61OBDaXKhk0oe/+i2FasQV0k
# lmJMZ+pVTxiPf1XbbAgB4qM2UlTeUCiQXxqNg55CbjosydOL7EbsKwdoEN3vzCOt
# fifseCFDCDLI8HYeW9LHKZD5ZUPpF4UWqsdHKWPGTPR7txhhUkXQUbavLBFKe2WU
# oliAuz0IEqL3l4HbUT231KClM1YRJvV5WEPHozQVZsoP+iEISaXnfE8dVCHFpfjS
# kesW9otD2Fd5HvhpoU6FcWbUeupxvN4uHw==
# SIG # End signature block
