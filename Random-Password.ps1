# ----------------------------------------------------------------------------------------------
# 	Get-Password PowerShell Script
#	
#	Author: John T Childers III
#	Originally Written: 7/5/2011
#		***Important****  
#       		Make sure to store this in a directory in that is a part of the path
#		so that it you can call it directly from powershell by typing Get-Password
# ----------------------------------------------------------------------------------------------

<#
.SYNOPSIS

Generate a random password.

.DESCRIPTION

The Get-Password function generates a random password from a pre-generated array of characters based of the length and complexity paramters defined at run time.  If no parameters are supplied the function defaults to a length of 9 characters and the high complexity character set which includes upper case letters, lower case letters, numbers and symbols.  The output is written to the console and is not stored anywhere else.

.PARAMETER -PasswordLength

Defines the number of random characters to generate for the password.  Also can be called by two alliases to provide for less typing which are -PassLen and -PL.

.PARAMETER -ComplexityLevel

Defines the complexity level of the password.  The options to be used are H for high complexity, M for medium complexity and L for low complexity.  Also can be called by the alias -CL.

.EXAMPLE

Generate a random password with the default settings of high complexity and 9 characters

Get-Password

.EXAMPLE 

Generate a password with 20 characters and low complexity(i.e. only letters)

Get-Password -PasswordLength 20 -ComplexityLevel L
#>

#Parameter configuration
Param 
	(
        #Defines the parameter for password length
		[Alias("PL")]
		[Alias("PassLen")]
		[Int]$PasswordLength = 15,
		
		#Defines the paramter for the complexity level of the password generated
		[Alias("CL")]
		[ValidateSet("H","M","L")]
		[String]$ComplexityLevel = "H"
			        
   )

Process 
	{
		
		# The array of characters below is used for the high complexity password generations
		$arrCharH = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0","!","@","#","$","%","&","^","*","(",")","-","+","=","_","{","}","\","/","?","<",">"
		
		# The array of characters below is used for the medium complexity password generations
		$arrCharM = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0"
		
		# The array of characters below is used for the low complexity password generations
		$arrCharL = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
		
		#Define the counter to be used in the for loop below
		$i = 1
		
		#Switch configuration to generate the appropriate complexity level defined by the -ComplexityLevel paramter
		Switch ($ComplexityLevel)
			{
				H { 
					For(; $i -le $PasswordLength; $i++)
						{
							$arrPass =  Get-Random -Input $arrCharH
							Write-Host $arrPass -NoNewLine
						}	
					Write-Host "`n"
				  }
				
				M { 
					For(; $i -le $PasswordLength; $i++)
						{
							$arrPass =  Get-Random -Input $arrCharM
							Write-Host $arrPass -NoNewLine
						}	
					Write-Host "`n"
				  }
				
				L { 
					For(; $i -le $PasswordLength; $i++)
						{
							$arrPass =  Get-Random -Input $arrCharL
							Write-Host $arrPass -NoNewLine
						}	
					Write-Host "`n"
				  }
				
			}	
	}