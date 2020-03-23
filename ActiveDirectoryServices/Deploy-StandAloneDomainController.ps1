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
    $Domain,
    [Parameter()]
    [String]
    $DomainNetBios, 
)

BEGIN{
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -Confirm:$false
$InformationPreference = "Continue"

$DCInstallArguments = @{

CreateDnsDelegation = $false
DomainMode = "WinThreshold"
DomainName = "yourdomain.com"
DomainNetbiosName = "YOURDOMAIN"
ForestMode = "WinThreshold"
InstallDns = $true
NoRebootOnCompletion = $false
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