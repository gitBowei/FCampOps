Import-Module ActiveDirectory

$Group = "Mobile Computers"
$GroupDescription = "Global security group for deploying DirectAccess Group Policy settings to mobile devices."
$Computer = "MOBILE"
$ComputerSearch = $Computer + '$'
$OUPath = "ou=Clients,ou=accounts,dc=corp,dc=contoso,dc=com" 
$ComputerDescription ="Windows 8.1 device connected to internet"

If ($(Get-ADObject -Filter {sAMAccountname -eq $ComputerSearch}) -ne $null){
    # If the computer account already exists, remove it
    Remove-ADComputer -Identity $Computer -Confirm:$false
}

# Add the computer account
New-ADComputer -Name $Computer -DisplayName $Computer -SAMAccountName $Computer -Path $OUPath -Description $ComputerDescription

If (Get-ADObject -Filter {sAMAccountname -eq $Group}){
    # If the group account already exists, remove it
    Remove-ADGroup -Identity $Group -Confirm:$false
}

# Add the global security group  accountNew-ADGroup -GroupScope global -Name $Group -Description $GroupDescription# Add the computer account to the membership of the group accountAdd-ADGroupMember -Identity $Group -Members $($Computer + "$")