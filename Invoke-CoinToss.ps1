Function Invoke-CoinToss {
 
[cmdletbinding(DefaultParameterSetName="_AllParameterSets")]
Param(
[Parameter(ParameterSetName="Boolean")]
[switch]$AsBoolean,
[Parameter(ParameterSetName="EvenOdd")]
[switch]$EvenOdd
)
 
Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"
 
#get a random number between 1 and 100 to test
$i = Get-Random -Minimum 1 -Maximum 100
Write-Verbose "Random result = $i"
 
#use the modulo operator
if ($i%2) {
    Write-Verbose "Odd/Heads/True"
    Switch ($PSCmdlet.ParameterSetName) {
     "Boolean" { $True}
     "EvenOdd" {"Odd" }
     Default {"Heads"}
    } #switch
} #if
else {
    Write-Verbose "Even/Tails/False"
    Switch ($PSCmdlet.ParameterSetName) {
     "Boolean" { $False}
     "EvenOdd" {"Even" }
     Default {"Tails"}
    } #switch
} #else
 
} #end Invoke-CoinToss

