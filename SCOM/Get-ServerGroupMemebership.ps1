<#
.SYNOPSIS
    Get the scom groups a server belongs to.
.DESCRIPTION
    gets the scom groups and associated management packs these accounts belong to.
.EXAMPLE
    PS C:\Get-SCOMNotificationSubscriptions.ps1 -ManagementServerName serverNetBiosName
    
.INPUTS
    -SCOMmanagementServer
        SCOM management server name
    -ComputerName
        Name of server you wish to find the groups for
.OUTPUTS
    ARRAY OF SCOM GROUPS CLASS, Name, ManagentPackname
.NOTES
    General note
#>
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $SCOMmanagementServer,
    [String]
    $ComputerName
)

BEGIN{

class ScomGroup {

[String]$Name
[String]$ManagementPackName
[String]$Health

}

$foundGroups = @()
$SCOMGroups = Get-SCOMGroup -ComputerName $SCOMmanagementServer

}

PROCESS{

foreach ($SCOMGroup in $SCOMGroups) {

    $GROUPNAME =  $SCOMGroup.DisplayName
    If ( ($SCOMGroup | Get-SCOMClassInstance -ComputerName  $SCOMmanagementServer | Where-Object {($_.DisplayName -ilike $ComputerName) -OR ($_.DisplayName -ilike "$($ComputerName).$($env:USERDNSDOMAIN)") }) ){
    Write-Information -MessageData  "FOUND IN $($GROUPNAME)" -InformationAction Continue
     $GroupClass = New-Object ScomGroup
     $GroupClass.Name = $SCOMGroup.DisplayName
     $GroupClass.Health = $SCOMGroup.HealthState
     $GroupClass.ManagementPackName = $SCOMGroup.GetClasses() | Select-Object 
     $foundGroups += $GroupClass
    }
    else{
    #Write-Information -MessageData  "NOT FOUND IN $($GROUPNAME)"
    }
}

}

END{

$foundGroups

}