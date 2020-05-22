New-ADUser -Name SCADMIN -GivenName SCADMIN -UserPrincipalName SCADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "C0l0mb1a2o17$" -Force) -Enabled $true
New-ADUser -Name EXADMIN -GivenName EXADMIN -UserPrincipalName EXADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "C0l0mb1a2o17$" -Force) -Enabled $true
New-ADUser -Name fcampo -GivenName "Fabian Campo" -UserPrincipalName FCAMPO -EmailAddress fcampo@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "C0l0mb1a2o17$" -Force) -Enabled $true
New-ADUser -Name lcampo -GivenName "Laura Campo " -UserPrincipalName LCAMPO -EmailAddress lcampo@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "C0l0mb1a2o17$" -Force) -Enabled $true
New-ADUser -Name Scampo -GivenName "Stephanie Campo" -UserPrincipalName SCAMPO -EmailAddress Scampo@campohenriquez.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "C0l0mb1a2o17$" -Force) -Enabled $true

New-ADGroup -Name Finance -SamAccountName Finance -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Marketing -SamAccountName Marketing -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Engineering -SamAccountName Engineering -GroupCategory Security -GroupScope Universal
New-ADGroup -Name Employees -SamAccountName Employees -GroupCategory Security -GroupScope Universal

Set-ADGroup Finance -Add @{mail='finance@campohenriquez.lab'}
Set-ADGroup Marketing -Add @{mail='marketing@campohenriquez.lab'}
Set-ADGroup Engineering -Add @{mail='engineering@campohenriquez.lab'}
Set-ADGroup Employees -Add @{mail='employees@campohenriquez.lab'}

Add-ADGroupMember -Identity Employees -Members fcampo,scampo,lcampo
Add-ADGroupMember -Identity Finance -Members fcampo
Add-ADGroupMember -Identity Marketing -Members scampo
Add-ADGroupMember -Identity Engineering -Members lcampo
Add-ADGroupMember -Identity "Enterprise Admins" -Members EXADMIN,SCADMIN