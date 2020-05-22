function Get-SysinternalsTools {
        <#
        .Synopsis
           Downloads the Sysinternals tools to the Machine
        .DESCRIPTION
           Downloads the Sysinternals tools to a specified directory using Bits Transfer.
        .PARAMETER Path
            Path to save the sysinternals executables.
        .EXAMPLE
           Get-SysinternalsTools -Path 'C:\Sysinternals' -Verbose -DownloadProtocol HTTP
        .EXAMPLE
           Get-SysinternalsTools -Path 'C:\Sysinternals' -DownloadProtocol SMB -Verbose
        #>
     
     [CmdletBinding()]
     
     Param
     (
      
      [Parameter(Mandatory = $true,
           ValueFromPipeline = $true,
           ValueFromPipelineByPropertyName = $true,
           ValueFromRemainingArguments = $false,
           Position = 0,
           HelpMessage = "Enter the path to wich you want to save the file.")]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [System.String]$Path,
      
      [Parameter(Mandatory = $true,
           Position = 0,
           HelpMessage = "Select the protocol you wish to use to Download the Tools")]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('SMB', 'HTTP')]
      $DownloadProtocol
      
     ) 