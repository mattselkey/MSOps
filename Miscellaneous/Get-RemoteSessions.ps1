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
    $Computername
)

$credentials = Get-Credential


Invoke-Command -ComputerName $Computername  -Credential $credentials -scriptblock {

$sessions = (QUERY SESSION /server:$Computername)

foreach($session in $sessions){

   Write-Host Hello $session

}

}