<#
.SYNOPSIS
    Connect to a remote server, check fors stopped services.
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


    Get-Service | Where-Object {($_.Status -eq "Stopped") -and ($_.StartType -eq "Automatic")}

}