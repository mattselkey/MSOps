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
    [Parameter(Mandatory = $true)]
    [String]
    $FQDNDomain,
    [Parameter(Mandatory = $true)]
    [String]
    $DomainNetBios,
    [Parameter(Mandatory = $true)]
    [String]
    $SafeModePass
)

BEGIN{
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -Confirm:$false
$InformationPreference = "Continue"
$DebugPreference = "Continue"
#$whatifpreference = 'True'

$secureString = ConvertTo-SecureString $SafeModePass -AsPlainText -Force


$DCInstallArguments = @{

CreateDnsDelegation = $false
DomainMode = "WinThreshold"
DomainName = $FQDNDomain
DomainNetbiosName = $DomainNetBios
ForestMode =  "WinThreshold"
InstallDns = $true
NoRebootOnCompletion = $false
Force = $true
SafeModeAdministratorPassword = $secureString
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
try {
if ($checkADService.InstallState -ne "Installed"){

Write-Information -MessageData "Installing services and management tools"

Install-windowsfeature AD-Domain-Services

}
}catch{

Write-Debug -Message "Error installing ad domain services. Error is $($_)"

exit

}


#Install First Domain controller


try {
Write-Information -MessageData "Installing active directory forest"

Install-ADDSForest @DCInstallArguments -Whatif

}catch{

Write-Debug -Message "Error installing ad ds forest. Error is $($_)"

exit


}





}

END{

}