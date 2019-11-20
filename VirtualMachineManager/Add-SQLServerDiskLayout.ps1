<#
.SYNOPSIS
    Add a SQL Server disk layout.
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\>.\Add-SQLServerDiskLayout.ps1 -VMMServer $VMMServerName -Hostname $HostName -DDriveSizeGB 100 -EDriveSizeGB 20 -UserDataSizeGB 20 -UserLogSizeGB 20 -TempDBSizeGB 20 -TempDBLogSizeGB 10
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
    [int32]$DDriveSizeGB = 100,
	[Parameter(Mandatory=$False)]
    [int32]$EDriveSizeGB = 10,
	[Parameter(Mandatory=$False)]
    [int32]$UserDataSizeGB = 100,
	[Parameter(Mandatory=$False)]
    [int32]$UserLogSizeGB = 25,
	[Parameter(Mandatory=$False)]
    [int32]$TempDBSizeGB = 25,
	[Parameter(Mandatory=$False)]
    [int32]$TempDBLogSizeGB = 25,
    [Parameter(Mandatory=$False)]
    [boolean]$OutInfo=$True
)

BEGIN{
    
    if($OutInfo){
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Information "messages will be passed to output stream."
    }else{
        $VerbosePreference = "SilentlyContinue"
         $InformationPreference = "SilentlyContinue"
    }

    #$ErrorActionPreference = "Stop"

    [double]$TotalAdditionsInGB = ($DDriveSizeGB + $EDriveSizeGB + $UserLogSizeGB + $TempDBSizeGB + $TempDBLogSizeGB) 


 function Get-ClusterStorage{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $VMMServer,
        [Parameter()]
        [String]
        $Hostname
    )

     #get Virtual machine hostname, location (cluster storage path e.g c:\clustervolume\..., )
     $VMDisks = Get-SCVirtualMachine -VMMServer $VMMServer -Name $Hostname  | Select-Object HostName, Location, VirtualDiskDrives
     $path = ($VMDisks.Location) -replace "\\$serverName",""
     $DiskInfo = Get-SCStorageVolume -VMHost $VMDisks.HostName  | Select-Object Name, FreeSpace | Where-Object { $_.Name -eq $path }

     [double]$freeSpaceBinary = [math]::round( $DiskInfo.FreeSpace / 1073741824)
     #Write-Information "$freeSpaceBinary.GetType()"
     #Write-Information "$freeSpaceBinary"
     return [double]$freeSpaceBinary
    }

}

PROCESS{
try
{
    
    [double]$freeSpace = (Get-ClusterStorage -VMMServer $VMMServer -Hostname $Hostname)
    
    Write-Information -MessageData "Total amount of Data that will be created will be: $($TotalAdditionsInGB) GB" 
    Write-Information -MessageData "Total amount of Free space on the cluster host partition is: $($freeSpace) GB"

    $newFreeSpace = ($freeSpace - $TotalAdditionsInGB)
    
    Write-Information -MessageData "Expected Free Space on the cluster if you continue will be: $($newFreeSpace) GB"

   $Prompt = Read-Host "Do you wish to continue? Yes[Y] or [N]"  

   switch($prompt){
       
     Y {
       $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $Hostname

        if ($null -ne $VM)
        {
            if ( (Get-SCVirtualDiskDrive -VM $VM).Count -lt 7)
            {
                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk1-D -SCSI -Bus 0 -LUN 1 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $DDriveSizeGB) | Out-Null
                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk2-E -SCSI -Bus 0 -LUN 2 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $EDriveSizeGB) | Out-Null

                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk3-UserDB -SCSI -Bus 0 -LUN 3 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $UserDataSizeGB) | Out-Null
                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk4-UserLog -SCSI -Bus 0 -LUN 4 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $UserLogSizeGB) | Out-Null

                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk5-TempDB -SCSI -Bus 0 -LUN 5 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $TempDBSizeGB) | Out-Null 
                New-SCVirtualDiskDrive -VM $VM -Dynamic -FileName Disk6-TempLog -SCSI -Bus 0 -LUN 6 -VirtualHardDiskFormatType VHDX -VirtualHardDiskSizeMB (1024 * $TempDBLogSizeGB) | Out-Null 
            }
            else{
                Write-Information -MessageData "$($VM) appears to already have the correct number of drives"
                #add info to display names and sizes
            }
        }else{

            Write-Information -MessageData "$($VM) cannot be found. No changes will be made."
            }
        }
        N{
    
    
        Write-Information -MessageData "No changes will be made."
    
        }
    }


}
catch { 
    Write-Error  "Error adding: $($_)"
    }

}

END{



}
