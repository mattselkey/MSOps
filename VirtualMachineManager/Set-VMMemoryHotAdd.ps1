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
    $VMMserver,
    [String]
    $serverName,
    [Int32]
    $Memory
)


$VM =Get-SCVirtualMachine -VMMServer $VMMserver -Name  $serverName
Set-SCVirtualMachine -VM $VM -MemoryMB $Memory