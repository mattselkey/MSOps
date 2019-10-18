<#
.SYNOPSIS
Extend a VMM guests harddisk partiton.
.DESCRIPTION
This script first checks the VM host storage to ensure that enough free space is available for the expansion.
.EXAMPLE
PS C:\> <example usage>
Explanation of what the example does
.INPUTS
Inputs (if any)
.OUTPUTS
Output (if any)
.NOTES
Assumes that the VMM cmdlets are already imported on the machine this script is run from.
#>
[CmdletBinding()]
Param(
[Parameter(Mandatory)]
[String]$VMMmanagementServer,
[Parameter(Mandatory)]
[String]$VMName
)

$vm = Get-SCVirtualMachine $VMName  

if($vm.Generation -eq "1"){
"Write-Output VM is generation 1, the machine needs to be powered down to complete a disk extension"
exit
}

$VMStorage = $vm | Get-SCVirtualHardDisk | Select-Object Name, HostVolume,
@{label="SizeGB";Expression={ "{0:F0}" -f ($($_.Size)/1GB) }},`
@{label="MaxGB";Expression={ "{0:F0}" -f ($($_.MaximumSize/1GB))}},`
@{label="PercentageGBFree";Expression={"{0:F0}" -f (100 -(   (100/("{0:F0}" -f  ($($_.MaximumSize)/1GB)) )*("{0:F1}" -f ($($_.Size)/1GB))))}}

Write-Host vm storage is: -ForegroundColor Green 
$VMStorage

$Storage = Get-SCStorageVolume -VMMServer $VMMmanagementServer | Select-Object Volumelabel, Name, VMHost,`
@{label="CapacityGB";Expression={ "{0:F0}" -f ($($_.Capacity)/1GB) }},`
@{label="FreeSpaceGB";Expression={ "{0:F0}" -f ($($_.FreeSpace)/1GB) }},`
@{label="PercentageGBFree";Expression={"{0:F0}" -f (   (100/("{0:F0}" -f  ($($_.Capacity)/1GB)) )*("{0:F1}" -f ($($_.FreeSpace)/1GB)))}} | 
Where-Object {$_.Name -eq $VMStorage.HostVolume } | Get-Unique

Write-Host VMM Cluster storage is: -ForegroundColor Green 
$Storage


$VMcimSession = New-CimSession -ComputerName $VMName
Write-Host Remote parition is: -ForegroundColor Green 
Get-Partition -Session $VMcimSession | Select-Object PartitionNumber, DriveLetter, Size, IsSystem | Where-Object {"" -ne $_.DriveLetter}