﻿##########################################################
#            Take Virtual machine Snapshots              #
#                                                        #
#                                                        # 
#                Microsoft Learning                      #
#                                                        #
#                 18th Jan 2014                          #   
#                      v1.0                              #
##########################################################



########## Take VM Snapshots of Configured  Virtual Machines  #######################################

#Define the Virtual machine names as variables to be used throughout the script
#If re-using on a new course. This should be the only thing that needs to be updated for any course. The remainder of the script remainds the same
# To add additional VMs just add definitions here or to remove Vms for your course just comment out as you need.
$VM1="20412D-LON-DC1"
$VM2="20412D-LON-SVR1"
$VM3="20412D-LON-SVR2"
$VM4="20412D-LON-SVR3"
$VM5="20412D-LON-SVR4"
$VM6="20412D-LON-CA1"
$VM7="20412D-TREY-DC1"
$VM8="20412D-TREY-CL1"
$VM9="20412D-TOR-DC1"
$VM10="20412D-LON-CL1"
$VM11="20412D-LON-CL2"
$VM12="20412D-LON-CORE"


#Prompt User for name to use for SnapShot, 
$SnapShotName = Read-Host "What do you want to call the Snapshot? If you press Enter or enter whitespace the current date/time Stamp will be used"


If([string]::IsNullOrWhiteSpace($snapshotname)) 
{            
    $SnapShotName = get-date      
    Write-Host  "We will use << $SnapShotName >> as the Snapshot name " `n
} 



#See if snapshot with that name already exist and assign True or False value to the Variable to track if they do or not
# If you need to add VMs you can just copy in the preceding lin and renumber
$VM1SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM1 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM2SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM2 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM3SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM3 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM4SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM4 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM5SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM5 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM6SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM6 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM7SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM7 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM8SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM8 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM9SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM9 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM10SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM10 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM11SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM11 | where {$_.name -eq "$SnapShotName"}).count -ne 0)
$VM12SnapShotNameNotExists = ((Get-VMSnapshot -VMName $VM12 | where {$_.name -eq "$SnapShotName"}).count -ne 0)


# If statement to check if $SnapShotName snapshot already exists for $VM1, if it does prompt saying so, otherwise take snapshot
if ($VM1SnapShotNameNotExists -eq "False")
{
write-host "$VM1 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM1 -SnapshotName $SnapShotName
write-Host " $VM1  --- $SnapShotName  -- created successfully"
}



# If statement to check if $SnapShotName snapshot already exists for $VM2, if it does prompt saying so, otherwise take snapshot
if ($VM2SnapShotNameNotExists -eq "False")
{
write-host "$VM2 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM2 -SnapshotName $SnapShotName
write-Host " $VM2  --- $SnapShotName  -- created successfully"
}



# If statement to check if $SnapShotName snapshot already exists for $VM3, if it does prompt saying so, otherwise take snapshot
if ($VM3SnapShotNameNotExists -eq "False")
{
write-host "$VM3 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM3 -SnapshotName $SnapShotName
write-Host " $VM3  --- $SnapShotName  -- created successfully"
}



# If statement to check if $SnapShotName snapshot already exists for $VM4, if it does prompt saying so, otherwise take snapshot
if ($VM4SnapShotNameNotExists -eq "False")
{
write-host "$VM4 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM4 -SnapshotName $SnapShotName
write-Host " $VM4  --- $SnapShotName  -- created successfully"
}


# If statement to check if $SnapShotName snapshot already exists for $VM5, if it does prompt saying so, otherwise take snapshot
if ($VM5SnapShotNameNotExists -eq "False")
{
write-host "$VM5 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM5 -SnapshotName $SnapShotName
write-Host " $VM5  --- $SnapShotName  -- created successfully"
}



# If statement to check if $SnapShotName snapshot already exists for $VM6, if it does prompt saying so, otherwise take snapshot
if ($VM6SnapShotNameNotExists -eq "False")
{
write-host "$VM6 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM6 -SnapshotName $SnapShotName
write-Host " $VM6  --- $SnapShotName  -- created successfully"
}




# If statement to check if $SnapShotName snapshot already exists for $VM7, if it does prompt saying so, otherwise take snapshot
if ($VM7SnapShotNameNotExists -eq "False")
{
write-host "$VM7 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM7 -SnapshotName $SnapShotName
write-Host " $VM7  --- $SnapShotName  -- created successfully"
}



# If statement to check if $SnapShotName snapshot already exists for $VM8, if it does prompt saying so, otherwise take snapshot
if ($VM8SnapShotNameNotExists -eq "False")
{
write-host "$VM8 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM8 -SnapshotName $SnapShotName
write-Host " $VM8  --- $SnapShotName  -- created successfully"
}

# If statement to check if $SnapShotName snapshot already exists for $VM9, if it does prompt saying so, otherwise take snapshot
if ($VM9SnapShotNameNotExists -eq "False")
{
write-host "$VM9 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM9 -SnapshotName $SnapShotName
write-Host " $VM9  --- $SnapShotName  -- created successfully"
}


# If statement to check if $SnapShotName snapshot already exists for $VM10, if it does prompt saying so, otherwise take snapshot
if ($VM10SnapShotNameNotExists -eq "False")
{
write-host "$VM10 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM10 -SnapshotName $SnapShotName
write-Host " $VM10  --- $SnapShotName  -- created successfully"
}

# If statement to check if $SnapShotName snapshot already exists for $VM11, if it does prompt saying so, otherwise take snapshot
if ($VM11SnapShotNameNotExists -eq "False")
{
write-host "$VM11 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM11 -SnapshotName $SnapShotName
write-Host " $VM11  --- $SnapShotName  -- created successfully"
}

# If statement to check if $SnapShotName snapshot already exists for $VM12, if it does prompt saying so, otherwise take snapshot
if ($VM12SnapShotNameNotExists -eq "False")
{
write-host "$VM12 --  $SnapShotName   ----  snapshot name already exists. Snapshot not created"
} 
else
{
checkpoint-VM -Name $VM12 -SnapshotName $SnapShotName
write-Host " $VM12  --- $SnapShotName  -- created successfully"
}



# SIG # Begin signature block
# MIIavQYJKoZIhvcNAQcCoIIarjCCGqoCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUG7K7og4S9OajTsmRPpHqkAxx
# slegghWCMIIEwzCCA6ugAwIBAgITMwAAAEyh6E3MtHR7OwAAAAAATDANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTMxMTExMjIxMTMx
# WhcNMTUwMjExMjIxMTMxWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkMwRjQtMzA4Ni1ERUY4MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsdj6GwYrd6jk
# lF18D+Z6ppLuilQdpPmEdYWXzMtcltDXdS3ZCPtb0u4tJcY3PvWrfhpT5Ve+a+i/
# ypYK3EbxWh4+AtKy4CaOAGR7vjyT+FgyeYfSGl0jvJxRxA8Q+gRYtRZ2buy8xuW+
# /K2swUHbqs559RyymUGneiUr/6t4DVg6sV5Q3mRM4MoVKt+m6f6kZi9bEAkJJiHU
# Pw0vbdL4d5ADbN4UEqWM5zYf9IelsEEXb+NNdGbC/aJxRjVRzGsXUWP6FZSSml9L
# KLrmFkVJ6Sy1/ouHr/ylbUPcpjD6KSjvmw0sXIPeEo1qtNtx71wUWiojKP+BcFfx
# jAeaE9gqUwIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFLkNrbNN9NqfGrInJlUNIETY
# mOL0MB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAAmKTgav6O2Czx0HftcqpyQLLa+aWyR/lHEMVYgkGlIVY+KQ
# TQVKmEqc++GnbWhVgrkp6mmpstXjDNrR1nolN3hnHAz72ylaGpc4KjlWRvs1gbnk
# PUZajuT8dTdYWUmLTts8FZ1zUkvreww6wi3Bs5tSLeA1xbnBV7PoPaE8RPIjFh4K
# qlk3J9CVUl6ofz9U8IHh3Jq9ZdV49vdMObvd4NY3DpGah4xz53FkUvc+A9jGzXK4
# NDSYW4zT9Qim63jGUaANDm/0azxAGmAWLKkGUp0cE5DObwIe6nucs/b4l2DyZdHR
# H4c6wXXwQo167Yxysnv7LIq0kUdU4i5pzBZUGlkwggTsMIID1KADAgECAhMzAAAA
# sBGvCovQO5/dAAEAAACwMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTEzMDEyNDIyMzMzOVoXDTE0MDQyNDIyMzMzOVowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAOivXKIgDfgofLwFe3+t7ut2rChTPzrbQH2zjjPmVz+l
# URU0VKXPtIupP6g34S1Q7TUWTu9NetsTdoiwLPBZXKnr4dcpdeQbhSeb8/gtnkE2
# KwtA+747urlcdZMWUkvKM8U3sPPrfqj1QRVcCGUdITfwLLoiCxCxEJ13IoWEfE+5
# G5Cw9aP+i/QMmk6g9ckKIeKq4wE2R/0vgmqBA/WpNdyUV537S9QOgts4jxL+49Z6
# dIhk4WLEJS4qrp0YHw4etsKvJLQOULzeHJNcSaZ5tbbbzvlweygBhLgqKc+/qQUF
# 4eAPcU39rVwjgynrx8VKyOgnhNN+xkMLlQAFsU9lccUCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBRZcaZaM03amAeA/4Qevof5cjJB
# 8jBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# NGZhZjBiNzEtYWQzNy00YWEzLWE2NzEtNzZiYzA1MjM0NGFkMB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQAx124qElczgdWdxuv5OtRETQie
# 7l7falu3ec8CnLx2aJ6QoZwLw3+ijPFNupU5+w3g4Zv0XSQPG42IFTp8263Os8ls
# ujksRX0kEVQmMA0N/0fqAwfl5GZdLHudHakQ+hywdPJPaWueqSSE2u2WoN9zpO9q
# GqxLYp7xfMAUf0jNTbJE+fA8k21C2Oh85hegm2hoCSj5ApfvEQO6Z1Ktwemzc6bS
# Y81K4j7k8079/6HguwITO10g3lU/o66QQDE4dSheBKlGbeb1enlAvR/N6EXVruJd
# PvV1x+ZmY2DM1ZqEh40kMPfvNNBjHbFCZ0oOS786Du+2lTqnOOQlkgimiGaCMIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBKUwggSh
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAAAsBGvCovQO5/d
# AAEAAACwMAkGBSsOAwIaBQCggb4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFI+x
# sbimAWK0pXyCvNoBC2cKG/2HMF4GCisGAQQBgjcCAQwxUDBOoCaAJABNAGkAYwBy
# AG8AcwBvAGYAdAAgAEwAZQBhAHIAbgBpAG4AZ6EkgCJodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vbGVhcm5pbmcgMA0GCSqGSIb3DQEBAQUABIIBAD6ul49CgjCCxTxJ
# QaP+fsAuliCZtuvRZN69geMI24IknqUqFMFMfNVqBiA4V5/uH33gIfn7weNaG4ad
# hM6mhs6UewbSGST+QkPY1NGE+aEb9BYzvPYeNGbR2e9lEHpXbXadNGC0C5w+VSHp
# 4BOxQP9yJL2svpU3V5fimT5XsXdF2jlCQXKXf+PlW6EvTAFHtP+Kv6gvKa3ZHAQF
# htYlMJ50BAA95JqDDzpGnV4PwNsewkuvk7jrobYFwqQShwt6aNNIbR0TbuC9AA1C
# q5fKYC8u5Ouki1Ndyuju7/MPt72fzPE8T6t3ajYDqW0FswG+vZ0638zxwakejdPw
# 7V+u9cqhggIoMIICJAYJKoZIhvcNAQkGMYICFTCCAhECAQEwgY4wdzELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBAhMzAAAATKHoTcy0dHs7AAAAAABMMAkGBSsOAwIaBQCg
# XTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDAy
# MjcwNzQzNDdaMCMGCSqGSIb3DQEJBDEWBBSB1DJbg1r4XTgjvhWow5UjgDRAFTAN
# BgkqhkiG9w0BAQUFAASCAQAr5rYXsc87KNQ2EPiCg5AtMCsCnl60cYa2/tCEdSIr
# IqhTS81ywAt0EHBmME4KcbVMDqutot9OHYKQeajYOqFpMysCJKsRSj9Z85sLj7vL
# A52pi0DwKN9bblz/0W7GJPNeV8TKRQJKmnruekN+hLZ2sThtkNj0PYkPgHnpdLqV
# ZRh2EL5Gm8E0QvoAGC9LKEnCx/KNWXhQXgqKs6Rg4PQvtGMFR4pj/H/fYWMFV1BW
# F9Yjj1e/Zju2d7hCAt6nd8MeZfgmF212pb0/g7OkhFM9BpCpl09RK8/74V4Lq+Ft
# 52kdmJ4pMYql4MNIp958M+7xpkSiwRR+6bNYLgYSr0wq
# SIG # End signature block
