<#
.SYNOPSIS
    get network folder file permissions, groups, users
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
    $NetworkFSPath,
    [Parameter()]
    [String]
    $Domain="$env:USERDOMAIN"
)


BEGIN{
$GroupsMembers = @()
}

process{

$permissions = (Get-Acl -Path "$NetworkFSPath").Access | Select-Object FileSystemRights, IdentityReference, IsInherited


foreach ($permission in $permissions){

#Write-Host (($permission.IdentityReference).value).GetType();


if ($($permission.IdentityReference).value -imatch $Domain ){
    Write-Host $($permission.IdentityReference).value
    $groupidentity = $($($permission.IdentityReference).value).TrimStart("$Domain\")
    Write-Host $groupidentity 
    $GroupsMembers += (Get-ADGroupMember -Identity $groupidentity)
    }
    }
}

END{
$permissions | Out-GridView
$GroupsMembers | Select-Object name | Out-GridView
#$GroupsMembers | Sort-Object Name ; 
}

