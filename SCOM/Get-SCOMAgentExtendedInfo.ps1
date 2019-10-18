<#
.SYNOPSIS
    This script checks if a server is managed by SCOM and then returns extended details about its SCOM configuration
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
    [String]$SCOMSERVERName,
    [Parameter()]
    [String]$ScomAgentName   
)

function get-scomHealthService{
param (
    [Parameter()]
    [String]$ScomAgentName   
)
    try{
        $service = Get-Service -ComputerName $ScomAgentName -ServiceName "HealthService"
    }
    catch{ 
    Write-Error   
    }
    return $service
}


$Agent = Get-SCOMAgent -ComputerName $SCOMSERVERName -DNSHostName "$($ScomAgentName)*"

if($null -eq $Agent){

    get-scomHealthService -ScomAgentName $ScomAgentName


}
else{

$HealthSRV = get-scomHealthService -ScomAgentName $ScomAgentName
$HealthSRV


}

