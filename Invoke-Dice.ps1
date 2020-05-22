Function Invoke-Dice {

[cmdletbinding()]
Param(
[ValidateRange(1,10)]
[int]$Dice = 2,
[ValidateRange(6,12)]
[int]$Sides = 6,
[Alias("Total")]
[switch]$Sum
)

Write-Verbose "Rolling $dice $sides-sided dice"

#generate a list of all possible numbers then select all random numbers at once
$result = (1..$Sides)*$Dice | Get-Random -Count $Dice

if ($sum) {
    write-Verbose "Totaling the result"
    Write-Verbose $($result -join ",")
    ($result | Measure-Object -sum).Sum
}
else {
    $result
}

} #end roll-dice

Set-Alias -name Roll-Dice -value Invoke-Dice