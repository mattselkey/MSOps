<#
.SYNOPSIS
    Get a partitions' Total and Free disk space
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

$Crendentials = Get-Credential

$disk = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName -Credential  $Crendentials -Filter "DeviceID='$($partition):'" |
Select-Object Size,FreeSpace

Write-information -m Total Disk Space ($disk.Size/1GB)
Write-Output Free Disk Space $disk.FreeSpace/1GB