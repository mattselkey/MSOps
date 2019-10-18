<#
.SYNOPSIS
    A script to return details on a managed scom server.
.DESCRIPTION
    This script checks if a server is managed by SCOM and then returns healthService status and the Groups the server belongs to.
.EXAMPLE
    PS C:.\Get-SCOMAgentExtendedInfo.ps1 -SCOMSERVERName subdn575 -ScomAgentName  SUBDN510
.INPUTS
   management server name and netbios/fqdn of server
.OUTPUTS
    health service staus and Groups the server belongs to
.NOTES
    Operations Manager modules need to be available.
#>

[CmdletBinding()]
param (
    [Parameter()]
    [String]$SCOMSERVERName,
    [Parameter()]
    [String]$ScomAgentName   
)

Import-module OperationsManager

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

#Function below Modified from https://community.squaredup.com/answers/question/how-do-i-find-what-group-ive-put-a-server-into/
function Get-SCOMAgentComputerGroups{
param (
    [Parameter()]
    [String]$SCOMSERVERName,
    [Parameter()]
    [String]$ScomAgentName  
)

$computerClass = Get-SCOMClass -ComputerName $SCOMSERVERName -Name “Microsoft.Windows.Computer”
$computer = Get-SCOMClassInstance -ComputerName $SCOMSERVERName -Class $computerClass | Where-Object {($_.FullName -eq $ScomAgentName) -or ($_.'[Microsoft.Windows.Computer].NetbiosComputerName'.value -eq $ScomAgentName)}

$relation1 = Get-SCOMRelationship  -ComputerName $SCOMSERVERName  -Name “Microsoft.SystemCenter.ComputerGroupContainsComputer”
$relation2 = Get-SCOMRelationship  -ComputerName $SCOMSERVERName  -Name “Microsoft.SystemCenter.InstanceGroupContainsEntities”
Get-SCOMRelationshipInstance  -ComputerName $SCOMSERVERName -TargetInstance $computer | 
Where-Object {!$_.isDeleted -and ( ($_.RelationshipId -eq $relation1.Id) -or ($_.RelationshipId -eq $relation2.Id) )} | Sort-Object SourceObject
}

$Agent = Get-SCOMAgent -ComputerName $SCOMSERVERName -DNSHostName "$($ScomAgentName)*"

if($null -eq $Agent){
    get-scomHealthService -ScomAgentName $ScomAgentName
}
else{
    $HealthSRV = get-scomHealthService -ScomAgentName $ScomAgentName
    $HealthSRV
    $groups = Get-SCOMAgentComputerGroups -SCOMSERVERName $SCOMSERVERName -ScomAgentName $ScomAgentName | Select-Object @{Name="Groups"; Expression={ $_.SourceObject}  } | Format-Table
    $groups
}


