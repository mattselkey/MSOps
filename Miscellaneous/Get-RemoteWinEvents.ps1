<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $ComputerName,
    [Parameter()]
    [String]
    [ValidateSet("Application", "Security", "System","Operations Manager")]
    $LogName,
    [Parameter()]
    [Int32]
    $EventID,
    [Parameter()]
    [String]
    [ValidateSet("Days", "Hours")]
    $TimeFrame,
    [Parameter()]
    [Int32]
    $Measure

)

if($TimeFrame -eq "Days"){
$StartTime = (Get-Date).AddDays(-$($Measure))
}
if($TimeFrame -eq "Hours"){
$StartTime = ((Get-Date).AddHours(-$Measure))
}
$ScriptBlock  = {
    Get-WinEvent -FilterHashtable @{
        LogName=$args[0]
        Id=$args[1]
        StartTime=$args[2]
    }
}



$credentials = Get-Credential -
Test-WSMan  -ComputerName $ComputerName
Invoke-Command -ComputerName $Computername -Credential $credentials -ArgumentList $LogName,$EventID,$StartTime -scriptblock $ScriptBlock 

