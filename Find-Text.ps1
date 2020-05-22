function Find-text {
<# 
 .Synopsis
  Function to find text patterns in files in given folders

 .Description
  Function will search for the input text patterns in files under the
  input list of folders and their subfolders, and it will output list
  of files found.
  Function will display a progress bar indicating text patterns it's searching for,
  file it's currently searching in, and file number out of total number of files.
  Function returns a PS object with 2 properties: String, and File. String is the 
  text pattern found, and File is the full path where the text pattern was found.

 .Parameter TextPattern
  The string(s) to search for
  This is NOT case sensitive

 .Parameter FolderName
  The folder(s) to search in
  If absent, the function assumes current folder.

 .Parameter FilePattern
  This paramters limits the search to the files with the input file patterns
  If absent, the function assumes '*' vaule or all files.
  Examples:
    *
    *.doc
    *.txt,*.csv,abc??.xy?,*.pp*

 .Example
  Find-Text -TextPattern "numlock"
  This example will search for "numlock" in files under the current folder

 .Example
  Find-text -TextPattern numlock,boutros -FolderName \\xHost15\install\scripts -FilePattern *.txt,*.csv,*.ps1
  This example will search for "numlock" and "boutros" in files with the
  text patterns *.txt,*.csv,*.ps1 under the folder \\xHost15\install\scripts
  
 .Example
  Find-text "numlock","boutros" "\\xHost15\install\scripts",".\test"
  This example will find the text TextPatterns "numlock","boutros" in the 
  folders "\\server\share\folder",".\test" 

 .Example
  $Found = Find-text "numlock","boutros" "\\xHost15\install\scripts",".\test" 
  if ($Found) { $Found | Out-GridView }

  This example will find the text TextPatterns "numlock","boutros" in the 
  folders "\\xHost15\install\scripts",".\test" and display the output on the screen 

 .Example
  $Found = Find-text "numlock","boutros" "\\xHost15\install\scripts",".\test" 
  if ($Found) { $Found | Export-CSV ".\Found.csv" -NoTypeInformation }

  This example will find the text TextPatterns "numlock","boutros" in the 
  folders "\\xHost15\install\scripts",".\test" and export the results to CSV
  file ".\Found.csv" 
  
 .Link
  https://superwidgets.wordpress.com/category/powershell/

 .Notes
  Function by Sam Boutros
  v1.0 - 08/31/2014
    Known limitations:
    - Paths longer than 260 characters will not be searched
    - Paths where the user running this function has no permissions will be skipped

#>

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [ValidateNotNullorEmpty()]
            [String[]]$TextPattern, 
        [Parameter(Mandatory=$false,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=1)]
            [ValidateScript({ Test-Path $_ })]
            [String[]]$FolderName = ".\",
        [Parameter(Mandatory=$false,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=2)]
            [String[]]$FilePattern = "*"
    )
    
    $Result = @()
    Write-Host "Searching for '$($TextPattern -join ", ")' in folder(s) '$($FolderName -join ", ")'..." -ForegroundColor Green
    $FileCount = (Get-ChildItem $FolderName -Recurse -File -Include $FilePattern -ErrorAction SilentlyContinue).Count
    $i = 0
    $NotFound = $true
    $Duration = Measure-Command {
        foreach ($File in (Get-ChildItem -Path $FolderName -Recurse -File -Include $FilePattern -ErrorAction SilentlyContinue)) {
            $i++
            Write-Progress -Activity "Searching for '$($TextPattern -join ", ")' in file '$($File.FullName)'" -Status "Searched $i out of $FileCount..." -PercentComplete ($i/$FileCount*100)
            Write-Verbose "Searching for '$($TextPattern -join ", ")' in file '$($File.FullName)'"
            foreach ($String in $TextPattern) {
                if (Select-String -Pattern $String -Path $File.FullName -Quiet) {
                    Write-Verbose "'$String' found in '$($File.FullName )'"
                    $NotFound = $false
                    $Properties = [ordered]@{ String=$String ; File=$File.FullName }
                    $Found = New-Object -TypeName PSObject -Property $Properties
                    $Result += $Found
                }
            }
        }
    }
    if ($NotFound) { 
        Write-Host "TextPattern(s) '$($TextPattern -join ", ")' not found in folder(s) '$($FolderName -join ", ")'" -ForegroundColor Yellow
    } else {
       Write-Host "Finished searching in $($Duration.Minutes):$($Duration.Seconds) (min:sec)" -ForegroundColor Green
    }
    return $Result
}