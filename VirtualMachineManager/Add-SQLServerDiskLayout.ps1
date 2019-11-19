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
Param(
    [Parameter(Mandatory=$True)]
    [string]$VMMServer,
    [Parameter(Mandatory=$True)]
    [string]$Hostname,
	[Parameter(Mandatory=$False)]
    [int]$DataLunSizeGB = 100,
	[Parameter(Mandatory=$False)]
    [int]$LogLunSizeGB = 25,
	[Parameter(Mandatory=$False)]
    [int]$TempLunSizeGB = 25,
    [Parameter(Mandatory=$False)]
    [boolean]$OutInfo =$True
)

begin{
    if(!OutInfo){
        $VerbosePreference = "Continue"
    }else{
        $VerbosePreference = "SilentlyContinue"
    }
    $ErrorActionPreference = "Stop"
}

process{
try
{

    if ($null -ne $VMMServer)
    {
        $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $Hostname

        if ( (Get-SCVirtualDiskDrive -VM $VM).Count -lt 7)
        {
            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk1-D -SCSI -Bus 0 -LUN 1 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024*100) | Out-Null
            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk2-E -SCSI -Bus 0 -LUN 2 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024*10) | Out-Null

            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk3-UserDB -SCSI -Bus 0 -LUN 3 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $UserDBLunSizeGB) | Out-Null
            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk4-UserLog -SCSI -Bus 0 -LUN 4 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $UserLogLunSizeGB) | Out-Null

            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk5-TempDB -SCSI -Bus 0 -LUN 5 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $TempDBLunSizeGB) | Out-Null 
            New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk6-TempLog -SCSI -Bus 0 -LUN 6 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $TempLogLunSizeGB) | Out-Null 
        }
        else{
            Write-Information -MessageData "$($VM) appears to already have the correct number of drives"
            #add info to display names and sizes
        }
    }
    else
    {
        Write-Information -MessageData "cannot connect to $($VMMServer)" 
    }
}
catch { 
    Write-Error  "Error adding: $($_)"
    }

}

End{



}
