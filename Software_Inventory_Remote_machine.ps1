<#
				"Satnaam WaheGuru Ji"
		
	Author  : Aman Dhally
	Email	: amandhally@gmail.com
	Date	: 21-August-2012
	Time	: 15:35
	Script	: Software Inventory 
	Purpose	: List of all software installed on Remote Laptop or Sever.
	website : www.amandhally.net
	twitter : https://twitter.com/#!/AmanDhally 
	
				/^(o.o)^\  V.2 {Incuded Parameters and run for multiple servers}

#>

# ===========    Notes  =========================================================
# Currenlty I am saving the File in D:\ Driver you can change it as per your need.
# this only Support Windows 2008 Server or Later and Windows 7 and later.
# make Sure that you run this Script as Administrator.
# ================================================================================

#Declaring Parameters
	param (
	[array]$arrComputer="$env:computername"
	)
#variables 
	$date = (Get-Date).ToShortDateString()
	$filename = "SoftwareReport"
	$vUserName = (Get-Item env:\username).Value
	$vComputerName = (Get-Item env:\Computername).Value
	#$filepath = (Get-ChildItem env:\userprofile).value

## Html Style
	$a = "<style>"
	$a = $a + "BODY{background-color:Lavender ;}"
	$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
	$a = $a + "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:thistle}"
	$a = $a + "TD{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
	$a = $a + "</style>"
# removing old HTML Report if exists
	if (test-Path d:\$filename.html) { remove-Item d:\$filename.html;
	Write-Host -ForegroundColor white -BackgroundColor Red    "Old file removed"
	}
# Running Command 

	foreach ( $name in $arrComputer ) {
	write-Host "Testing Network Connection with $name" -ForegroundColor Green
	if ( Test-Connection $name -Count 2 -Quiet ) {
	write-Host "Getting software information." -ForegroundColor Magenta -BackgroundColor White 
	ConvertTo-Html -Title "Software Inventory" -Body "<h1> Computer Name : $name </h1>" >>  "d:\$filename.html"
	Get-WmiObject win32_Product -ComputerName $name | Select Name,Version,PackageName,Installdate,Vendor | Sort Installdate -Descending `
	                                         | ConvertTo-html  -Head $a -Body "<H2> Software Installed</H2>" >> "d:\$filename.html"								 
	} else {
		write-Host " $name is not found or not reachable." -ForegroundColor white -BackgroundColor Red
		}
	}
## Opening file and the file 
	$Report = "The Report is generated On  $(get-date) by $((Get-Item env:\username).Value) on computer $((Get-Item env:\Computername).Value)"
	$Report  >> "d:\$filename.html" 
	write-Host "file is saved in "D:\" and the name of file is $filename.html" -ForegroundColor Cyan
	invoke-Expression "d:\$filename.html" 
## END of the SCRIPT ## 

################################# a m a n D | 



