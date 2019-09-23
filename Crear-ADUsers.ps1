##Configuracion de ADDS desde PowerShell

New-ADUser -Name SQLSVC -GivenName SQLSVC -UserPrincipalName SQLSVC -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SYSADMIN -GivenName SYSADMIN -UserPrincipalName SYSADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name NHOLLIDA -GivenName "Nicole Holliday" -UserPrincipalName NHOLLIDA -EmailAddress nhollida@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name LHENIG -GivenName "Limor Henig " -UserPrincipalName LHENIG -EmailAddress lhenig@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SRAILSON -GivenName "Stuart Railson" -UserPrincipalName SRAILSON -EmailAddress srailson@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
##
New-ADUser -Name FCAMPO -GivenName "Fabian Campo" -UserPrincipalName FCAMPO -EmailAddress fcampo@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name PPARKER -GivenName "Peter Parker" -UserPrincipalName PPARKER -EmailAddress pparker@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name TSTARK -GivenName "Anthony Stark" -UserPrincipalName TSTARK -EmailAddress TSTARK@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SSTORM -GivenName "Sue Storm" -UserPrincipalName SSTORM -EmailAddress SSTORM@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name VDOOM -GivenName "Victor Von Dooom " -UserPrincipalName VDOOM -EmailAddress VDOOM@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JSTORM -GivenName "Johnny Storm" -UserPrincipalName JSTORM -EmailAddress JStorm@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name BGrim -GivenName "Ben Grim" -UserPrincipalName BGRIM -EmailAddress BGRIM@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name RRICHARDS -GivenName "Reed Richards" -UserPrincipalName RRICHARDS -EmailAddress RRICHARDS@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SROGERS -GivenName "Steve Rogers" -UserPrincipalName SROGERS -EmailAddress srogers@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name BBANNER -GivenName "Bruce Banner" -UserPrincipalName BBANNER -EmailAddress BBANNER@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
##
New-ADGroup -Name Finance -SamAccountName Finance -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Marketing -SamAccountName Marketing -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Engineering -SamAccountName Engineering -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Employees -SamAccountName Employees -GroupCategory Security -GroupScope Universal
New-ADGroup -Name 4Fantasticos -SamAccountName 4fantasticos -GroupCategory Security -GroupScope Universal
##
Set-ADGroup Financiero -Add @{mail='financiero@campohenriquez.lab'}
Set-ADGroup Mercadeo -Add @{mail='mercadeo@campohenriquez.lab'}
Set-ADGroup Ventas -Add @{mail='ventas@campohenriquez.lab'}
Set-ADGroup Employees -Add @{mail='employees@campohenriquez.lab'}
Set-ADGroup 4fantasticos -Add @{mail='4fantasticos@campohenriquez.lab'}
##
Add-ADGroupMember -Identity Employees -Members nhollida,lhenig,srailson,fcampo,pparker,tstark,sstorm,vdoom,jstorm,Bgrim,RRichards,Srogers,BBanner
Add-ADGroupMember -Identity Financiero -Members nhollida
Add-ADGroupMember -Identity Mercadeo -Members lhenig
Add-ADGroupMember -Identity 4fantasticos -Members bgrim,sstorm,jstorm,rrichards
Add-ADGroupMember -Identity Engineering -Members srailson
Add-ADGroupMember -Identity "Enterprise Admins" -Members sysadmin