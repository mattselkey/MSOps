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
    $MachineName
)

$credentials = Get-Credential
$cimSession = New-CimSession -ComputerName $MachineName -Credential $credentials

$partition = Get-Partition -CimSession $cimSession | Where-Object {$_.DriveLetter  -eq "C"}
$size  = Get-PartitionSupportedSize -CimSession $cimSession -DriveLetter C

Resize-Partition -CimSession $cimSession -DiskNumber $partition.DiskNumber -PartitionNumber $partition.PartitionNumber -Size $size.SizeMax