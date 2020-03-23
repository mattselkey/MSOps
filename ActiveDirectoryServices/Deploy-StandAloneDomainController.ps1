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


BEGIN{
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -Confirm:$false
$InformationPreference = "Continue"

$DCInstallArguments = @{

CreateDnsDelegation = $false
DatabasePath = "C:\Windows\NTDS"
DomainMode = "Win2012R2"
DomainName = "yourdomain.com"
DomainNetbiosName = "YOURDOMAIN"
ForestMode = "Win2012R2"
InstallDns = $true
LogPath = "C:\Windows\NTDS"
NoRebootOnCompletion = $false
SysvolPath = "C:\Windows\SYSVOL"
Force = $true


}


}

PROCESS{

$checkADService = Get-windowsfeature -Name AD-Domain-Services    


if($checkADService){

Write-Information -MessageData "AD Domain services are available"
}
else {
#Write-Information -MessageData "AD Domain services are NOT available. Installing services and management tools"
exit

}


#Install windows features
if ($checkADService.InstallState -ne "Installed"){

Write-Information -MessageData "Installing services and management tools"

Install -windowsfeature AD-Domain-Services

}


#Install First Domain controller



Install-ADDSForest @DCInstallArguments






}

END{

}