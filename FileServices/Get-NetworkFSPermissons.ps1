<#
.SYNOPSIS
    gte network folder file permissions, groups, users
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
    [TypeName]
    $NetworkFSPath
)


$permissions = (Get-Acl -Path "$NetworkFSPath").Access | Select-Object FileSystemRights, IdentityReference, IsInherited
Write-Output $permissions

