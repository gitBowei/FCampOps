function New-RandomPassword {
       [CmdletBinding()]
        param(
                [Int16] $Length = 6,
 
                [Int16] $NumberOfNonAlphaNumericCharacters = 3,
                               
                [Switch] $AsSecureString
        )
 
        Begin {
                try {
                        # Load required assembly.
                $assem = [System.Reflection.Assembly]::LoadWithPartialName('System.Web')
                } catch {
                        throw 'Failed to load required assembly [System.Web.Security]. The error was: "{0}".' -f $_
                }
        }
        
        Process {
                try {
                        $generatedPassword = [System.Web.Security.Membership]::GeneratePassword($Length, $NumberOfNonAlphaNumericCharacters)
                        if ($AsSecureString) {
                                return ConvertTo-SecureString -String $generatedPassword -AsPlainText -Force
                        } else {
                                return $generatedPassword
                        }
                } catch {
                        throw 'Failed to generate random password. The error was: "{0}".' -f $_
                }
        }
        
        End {
                Get-Variable | Where-Object {$_.Name -eq 'generatedPassword'} | Remove-Variable -Force
        }
        
        <#
                .SYNOPSIS
                        Generates a random password.
        
                .PARAMETER  Length
                        The password length.
        
                .PARAMETER  NumberOfNonAlphaNumericCharacters
                        The number of non-alphanumeric characters to include in the password.
                        
                .PARAMETER  AsSecureString
                        Return the password in the form of a secure string instead of clear text.
        
                .EXAMPLE
                        PS C:\> New-RandomPassword
        
                .EXAMPLE
                        PS C:\> New-RandomPassword -AsSecureString
        
                .INPUTS
                        None.
        
                .OUTPUTS
                        System.String, System.Security.SecureString
        
                .NOTES
                        Revision History
                                2011-08-26: Andy Arismendi - Created.
        
                .LINK
                        http://msdn.microsoft.com/en-us/library/system.web.security.membership.generatepassword.aspx
        #>
}
 
New-RandomPassword -Length 14

