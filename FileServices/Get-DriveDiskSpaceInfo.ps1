<#
.SYNOPSIS
    Get a partition free space and
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
Param(
[Parameter(Mandatory=$true)]
[String]$ComputerName,
[Parameter(Mandatory=$true)]
[String]$partition
)


$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName  -Filter "DeviceID='$($partition):'" |
Select-Object Size,FreeSpace

$disk.Size/1GB
$disk.FreeSpace/1GB