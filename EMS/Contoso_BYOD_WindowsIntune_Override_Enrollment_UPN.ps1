﻿New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDMNew-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM -Name DiscoveryService -PropertyType String -Value "manage.microsoft.com"