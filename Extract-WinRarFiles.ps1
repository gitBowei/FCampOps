################################################################
# Author: Ron Ratzlaff
# Script Title: Extract WinRAR Files PowerShell Tool
# Script File Name: Extract-WinRARFiles.ps1
# Date Created: 05/27/2017
################################################################ 


#Requires -Version 5.0


Function Extract-WinRarFiles
{
    <# 
      .SYNOPSIS 
       
          The Extract WinRAR Files Tool simply does what the name implies and extracts WinRAR files. 
         
      .DESCRIPTION 
       
          The Extract WinRAR Files Tool extracts WinRAR files from a specified source directory and places them in a specified target directory. There is a parameters that will allow the user to open up the target location once the files have been extracted as well as a parameter to delete the source directory. 
          
      .PARAMETER UnrarExePath
       
          Use this parameter to specify the path to the UnRar executable extraction tool that gets installed along with the WinRAR application. 
      
      .PARAMETER UnRarSourcePath
       
          Use this parameter to specify the source of the RAR (.rar) files that need to be extracted. 

      .PARAMETER UnRarTargetPath
       
          Use this parameter to specify the target location where the extracted files are to be placed. 
      
      .PARAMETER OpenTargetLocation
       
          Use this parameter to open the target directory where the extracted files are located.

      .PARAMETER DeleteSourceRarFiles
       
          Use this parameter to delete the parent directory where all the RAR files are located, including sub-directories if they exist.
      
      .EXAMPLE 
 
        Extract all RAR files from all subdirectories within a parent directory (recursive), located in a directory named "SourceRARFiles" and extract to a directory on the user's Desktop named "TargetRARFiles" and open the target folder after extraction and then delete the source folder afterward. 
 
        Extract-WinRarFiles -UnRarSourcePath "$env:TEMP\SourcetRARFiles" -UnRarTargetPath "$env:USERPROFILE\Desktop\TargetRARFiles" -OpenTargetLocation -DeleteSourceRarFiles
    
      #>  
      
      [cmdletbinding()]
    
    Param 
    (
        [Parameter(HelpMessage='Enter the local path to the unrar.exe program')]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({ Test-Path -Path $_ })] 
            [Alias('UREP')] 
            $UnRarExePath = "$env:ProgramFiles\WinRAR\UnRAR.exe",
            
        [Parameter(Mandatory = $true, 
            HelpMessage='Enter the local file path where the WinRar files are located that you would like to extract')]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({ Test-Path -Path $_ })]
            [Alias('URSP')]   
            $UnRarSourcePath,
        
        [Parameter(Mandatory = $true, 
            HelpMessage='Enter the local file path location you wish to extract the content to')]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({ Test-Path -Path $_ })]
            [Alias('URTP')]   
            $UnRarTargetPath,

        [Parameter(HelpMessage='Use this parameter to open the directory the extracted files are located in')]
            [ValidateNotNullOrEmpty()]
            [Alias('OTL')]   
            [switch]$OpenTargetLocation, 

        [Parameter(HelpMessage='Use this parameter to delete the original RAR files to help save disk space')]
            [ValidateNotNullOrEmpty()]
            [Alias('DSRF')]   
            [switch]$DeleteSourceRarFiles
    ) 

    Begin
    {
        $NewLine = "`r`n"
        
        $RarFilePaths = (Get-ChildItem -Path $UnRarSourcePath -Recurse | Where-Object -FilterScript { $_.extension -eq '.rar' }).FullName

        $RarFileSourceCount = $RarFilePaths.Count     
    }

    Process
    {
        $NewLine

        Write-Output -Verbose "Total RAR File Count: $RarFileSourceCount"

        $NewLine

        Write-Output -Verbose "Beginning extraction, please wait..."

        Start-Sleep -Seconds 5

        Foreach ($FilePath in $RarFilePaths)
        {
            &$UnRarExePath x -y $FilePath $UnRarTargetPath
        }

        $RarFileTargetCount = (Get-ChildItem -Path $UnRarTargetPath).Count

        If ($RarFileTargetCount -eq $RarFileSourceCount)
        {
            Clear-Host

            $NewLine

            Write-Output -Verbose "$RarFileTargetCount RAR files have been extracted"

            $NewLine
        }
        
        Else
        {
            $NewLine
            
            Write-Warning -Message "$RarFileTargetCount out of $RarFileSourceCount have been extracted"

            $NewLine
        }  
    }

    End
    {
        Switch ($PSBoundParameters.Keys)
        {
            { $_ -contains 'OpenTargetLocation' }
            {
                $NewLine

                Write-Output -Verbose 'Opening RAR target location...'

                Start-Sleep -Seconds 5
                
                Invoke-Item -Path $UnRarTargetPath
            }

            { $_ -contains 'DeleteSourceRarFiles' }
            {
                $NewLine

                Write-Output -Verbose 'Deleting source RAR files and the directory...'

                Start-Sleep -Seconds 5
                
                Remove-Item -Path $UnRarSourcePath -Recurse -Force
            }
        }
    }
}




