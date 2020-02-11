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
    [Parameter(Mandatory=$True)]
    [string]$SQLUser,
    [Parameter(Mandatory=$True)]
    [string]$SQLUserPwd,
    [Parameter(Mandatory=$False)]
    [string]$ConfigurationFilePath="",   
    [Parameter(Mandatory=$False)]
    [String]$ISOpath="",
    [Parameter(Mandatory=$False)]
    [String]$LocalFolder="c:\Temp",
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

    $checkISO = "$($LocalFolder)\*.iso"

    if(-Not (Test-Path $checkISO)){
        Write-Information "Moving SQL Server ISO to local temp folder"
        Robocopy.exe $ISOpath $LocalFolder *.iso
    }
    else{

        Write-Information "ISO already in place. ISO is: $($checkISO)"
    }

}

PROCESS{

    $isoInfo = Get-DiskImage -DevicePath \\.\CDROM0 -ErrorAction SilentlyContinue
    
    if($isoInfo){
        $volumeInfo = Get-Volume -ErrorAction SilentlyContinue
    }
    if(-not ($volumeInfo)){
        Write-Information "Mounting ISO"
        $LocalISO = Get-Item "$LocalFolder\*.iso"
        $mount = Mount-DiskImage $LocalISO
        $mount
    } 
    else{

        Write-Information "drive is already mounted: $($isoInfo)"

    }
    $drive = Get-CimInstance Win32_LogicalDisk | Where-Object  { $_.DriveType -eq 5} | Select-Object DeviceID 
    Write-Information "CD drive is: $($drive.DeviceID)"


    # &"$($drive.DeviceID)\setup.exe /IAcceptSQLServerLicenseTerms=`"True`" /SQLSVCACCOUNT=`"$($SQLUser)`"" +
    # " /SQLSVCPASSWORD=`"$($SQLUserPwd)`" /AGTSVCACCOUNT=`"$($SQLUser)`" /AGTSVCPASSWORD=`"$($SQLUserPwd)`"" +
    # " /SAPWD=`"$($SQLUserPwd)`" /ConfigurationFile=`"$($ConfigFilePath)`""

    Write-Information "Configuration path is: $($ConfigurationFilePath)"

    $HashArguments =
        "/IAcceptSQLServerLicenseTerms=`"True`"",
        "/SQLSVCACCOUNT=`"$($SQLUser)`"",
        "/SQLSVCPASSWORD=`"$($SQLUserPwd)`"",
        "/AGTSVCACCOUNT=`"$($SQLUser)`"",
        "/SAPWD=`"$($SQLUserPwd)`"",
        "/ConfigurationFile=`"$($ConfigurationFilePath)`""
        
    #$HashArguments
    & "$($drive.DeviceID)\setup.exe" @HashArguments


}

END{

   #Dismount-DiskImage -ImagePath  $LocalISO

}