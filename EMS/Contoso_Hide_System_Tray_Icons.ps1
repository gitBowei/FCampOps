# Script to disable icons in notification (system) tray

# Set variables used by script
$CompRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$UserRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$HideClockIcon = "HideClock"
$HideVolumeControlIcon = "HideSCAVolume"
$HideSecurityActionCenter = "HideSCAHealth"

# Hide the clock icon
New-ItemProperty -Path $CompRegPath -Name $HideClockIcon -PropertyType DWord -Value 0
New-ItemProperty -Path $UserRegPath -Name $HideClockIcon -PropertyType DWord -Value 0

# Hide the volume control (speaker) icon
New-ItemProperty -Path $CompRegPath -Name $HideVolumeControlIcon -PropertyType DWord -Value 0
New-ItemProperty -Path $UserRegPath -Name $HideVolumeControlIcon -PropertyType DWord -Value 0

# Hide the security action center icon
New-ItemProperty -Path $CompRegPath -Name $HideSecurityActionCenter -PropertyType DWord -Value 0
New-ItemProperty -Path $UserRegPath -Name $HideSecurityActionCenter -PropertyType DWord -Value 0

