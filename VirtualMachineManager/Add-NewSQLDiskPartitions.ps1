<#
.SYNOPSIS
    Set new partitions online, initiliaze and format
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
    [Parameter(Mandatory=$True)]
    [String]$PartitionOwner,
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

    $ErrorActionPreference = "Stop"

function FormatDiskDrive{
        [CmdletBinding()]
        param (
            [Parameter()]
            [String]
            $DiskNumber,
            [Parameter()]
            [string]$DriveLabel,
            [Parameter()]
            [string]$DriveLetter
            )


        $RootDir = "${DriveLetter}:\"
    
        if (-Not (Test-Path $RootDir))
        {
            try
            {
                Write-Information -MessageData  "Formatting directory ($RootDir)."
                $Partition = Get-Disk -Number $DiskNumber | New-Partition -UseMaximumSize
                $Volume = $Partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DriveLabel -Confirm:$false 
                $Partition | Add-PartitionAccessPath -AccessPath "${DriveLetter}:"
                if (-Not (Test-Path $RootDir))
                {
                  Write-Information -MessageData  "($RootDir) is not available, formatting has failed."
                  Pause
                  Exit-PSSession
                }
            }
            catch 
            {
                Write-Error  "Drive $($_) is already in place, nothing to do."
            }
        }
    }


function FormatDiskandMountPoint{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $DiskNumber,
        [Parameter()]
        [String]
        $DiskLabel,
        [Parameter()]
        [String]
        $MountPoint     
    )
        if (-Not (Test-Path $MountPoint))
        { $dummy = New-item -ItemType Directory $MountPoint }
    
        if (Test-Path $MountPoint)
        {
            try
            {
                $Partition = Get-Disk -Number $DiskNumber | New-Partition -UseMaximumSize
                $Volume = $Partition | Format-Volume -FileSystem NTFS -NewFileSystemLabel $Label -Confirm:$false -AllocationUnitSize 65536 
                $Partition | Add-PartitionAccessPath -AccessPath $MountPoint -PassThru | Set-Partition -NoDefaultDriveLetter:$True | Out-Null
                if ( (Get-Item $MountPoint).LinkType -ne "Junction"){

                    Write-Information -MessageData "cannot find Junction for $($MountPoint) on $($DiskNumber)/($Partition.PartitionNumber)"
                    Pause
                    Exit-PSSession                   
                }
            }
            catch {
                Write-Information -MessageData  "Error formatting and mounting disknumber $($DiskNumber) and $($MountPoint) $($_)"
            }
        }
    }
}

PROCESS{
try { 
    Write-Information -Message   "Setting disk to online." 
    Get-Disk | Where-Object {
        $_.OperationalStatus -eq "Offline" 
    } | ForEach-Object { Set-Disk -Number $_.Number -IsOffline $False } 

}catch 
{
    Write-Error -Message   "Setting disks online failed, error: $($_) " 
}

try { 
    Write-Information -Message   "Initialize disks and format." 
    Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW" } | ForEach-Object { Initialize-Disk -Number $_.Number -PartitionStyle GPT | Out-Null } }
catch {
    Write-Error -Message   "Setting disks online failed, error: $($_) " 
}
$permission  = "$PartitionOwner","FullControl", "ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission

#Format D Drive - SQL Installation Files
FormatDiskDrive -DiskNumber 1 -DriveLabel "SQL_System" -DriveLetter "D"
$acl = Get-ACL D:\
$acl.access | Where-Object { $_.IdentityReference -eq "CREATOR OWNER"} | ForEach-Object {$acl.RemoveAccessRule($_)}
$acl.access | Where-Object { $_.IdentityReference -eq "EveryOne"} | ForEach-Object {$acl.RemoveAccessRule($_)}
$acl.SetAccessRule($accessRule)
Set-ACL D:\ $acl


#Format E Drive - SQL Mount points
FormatDiskDrive -DiskNumber 2 -DriveLabel "SQL_Data_Root" -DriveLetter "E"
$acl = Get-ACL E:\
$acl.access | ? { $_.IdentityReference -eq "CREATOR OWNER"} | % {$acl.RemoveAccessRule($_)}
$acl.access | ? { $_.IdentityReference -eq "EveryOne"} | % {$acl.RemoveAccessRule($_)}
$acl.SetAccessRule($accessRule)
Set-ACL E:\ $acl

#Create Mount Points
FormatDiskandMountPoint -DiskNumber 3 -DiskLabel "User_DB"  -MountPoint "E:\User_DB"
FormatDiskandMountPoint -DiskNumber 4 -DiskLabel "User_Log" -MountPoint "E:\User_Log"
										
FormatDiskandMountPoint -DiskNumber 5 -DiskLabel "Temp_DB"  -MountPoint "E:\Temp_DB"
FormatDiskandMountPoint -DiskNumber 6 -DiskLabel "Temp_Log" -MountPoint "E:\Temp_Log"



}

END{


}