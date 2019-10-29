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
    [String]
    $LogName
)

$credentials = Get-Credential

Invoke-Command -ComputerName $Computername  -Credential $credentials -scriptblock {


    Get-WinEvent -ComputerName $CompputerName -LogName $LogName -
}


