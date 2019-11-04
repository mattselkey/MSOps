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
    $SCOMmanagementServer,
    [String]
    $ComputerName
)

$containmentRel = Get-RelationshipClass -name:’Microsoft.SystemCenter.InstanceGroupContainsEntities’
$computerClass = Get-MonitoringClass -name:”Microsoft.Windows.Computer”
$criteria = [string]::Format(“PrincipalName = ‘{0}’”,$computerFQDN)



 try {
 $computer = Get-MonitoringObject -comp -monitoringClass:$computerClass -criteria:$criteria
 $relatedObjects = $computer.GetMonitoringRelationshipObjectsWhereTarget($containmentRel,[Microsoft.EnterpriseManagement.Configuration.DerivedClassTraversalDepth]::Recursive,[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive)
 }
 catch {
 $_
 write-host “An error occurred while querying groups of $computerFQDN”
}

foreach($group in $relatedObjects)
 {
 [array]$Groups = $groups + $group.SourceMonitoringObject.DisplayName
 }
 if($groups) {
 return $groups
 } else {
 write-host “No groups available for $computerFQDN”
}
 }


