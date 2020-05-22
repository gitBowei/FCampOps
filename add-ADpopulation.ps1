##Configuracion de ADDS desde PowerShell

New-ADUser -Name SQLSVC -GivenName SQLSVC -UserPrincipalName SQLSVC -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SYSADMIN -GivenName SYSADMIN -UserPrincipalName SYSADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SCADMIN -GivenName SCADMIN -UserPrincipalName SCADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name HOrdonez -GivenName "Harold Ordonez" -UserPrincipalName HORDONEZ -EmailAddress hordonez@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JMejia -GivenName "Javier Mejia " -UserPrincipalName JMEJIA -EmailAddress jmejia@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name YDominguez -GivenName "Yaneth Dominguez" -UserPrincipalName YDominguez -EmailAddress ydominguez@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name FCampo -GivenName "Fabian Campo" -UserPrincipalName FCAMPO -EmailAddress fcampo@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true

##Avengers
New-ADUser -Name PPARKER -GivenName "Peter Parker" -UserPrincipalName PPARKER -EmailAddress pparker@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name TSTARK -GivenName "Anthony Stark" -UserPrincipalName TSTARK -EmailAddress TSTARK@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SROGERS -GivenName "Steve Rogers" -UserPrincipalName SROGERS -EmailAddress srogers@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name BBANNER -GivenName "Bruce Banner" -UserPrincipalName BBANNER -EmailAddress BBANNER@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true

##Fantastic 4
New-ADUser -Name SSTORM -GivenName "Sue Storm" -UserPrincipalName SSTORM -EmailAddress SSTORM@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name VDOOM -GivenName "Victor Von Dooom " -UserPrincipalName VDOOM -EmailAddress VDOOM@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JSTORM -GivenName "Johnny Storm" -UserPrincipalName JSTORM -EmailAddress JStorm@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name BGrim -GivenName "Ben Grim" -UserPrincipalName BGRIM -EmailAddress BGRIM@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name RRICHARDS -GivenName "Reed Richards" -UserPrincipalName RRICHARDS -EmailAddress RRICHARDS@comics.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true

##
New-ADGroup -Name Fantastic4 -SamAccountName Fantastic4 -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Avengers -SamAccountName Avengers -GroupCategory Security -GroupScope Universal

##
Set-ADGroup Fantastic4 -Add @{mail='fantastic4@comics.lab'}
Set-ADGroup Avengers -Add @{mail='Avengers@comics.lab'}

##
Add-ADGroupMember -Identity Avengers -Members PParker,TStark,SRogers,BBanner
Add-ADGroupMember -Identity Fantastic4 -Members bgrim,sstorm,jstorm,rrichards
Add-ADGroupMember -Identity "Enterprise Admins" -Members sysadmin,HOrdonez,JMejia,FCampo