<#
.SYNOPSIS
    Find an Active Directory user and return group membership, 
    returned groups can be filtered using the -App parameter
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> .\Get-UserApplicationsExtended.ps1 -Name Nikokras -App RDP
.INPUTS
    username (via -Name parameter - Mandatory) and application (via -App parameter - Not Mandatory) name
.OUTPUTS
    A list of Security groups in Out-GridView format
.NOTES
    
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[String]$Name,
[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
[String]$App = "*"
)

function get-adUserbyname{
        Param(
            [Parameter(Mandatory)]
            [String]$NameFilter
            )

        $NameFilter = 'name -like "*' + $($Name) +'*"'
        $ADUsers =  Get-ADUser -Filter $NameFilter 
        if ($null -eq $ADUsers){
    
            $ADUsers =  Get-ADUser $Name 
        }
        return  $ADUsers
}

$ADUsers = get-adUserbyname $Name

 while ($NULL -eq $ADUsers) {
        Write-Host "user not found"
        $Name = Read-Host "Input user name"
        $ADUsers = get-adUserbyname $Name
    }

if($ADUsers.count -gt 1){

    Write-Host "$($ADUsers.count) Users have been found, do you want to continue?" -ForegroundColor Green
    $Name = Read-Host "Type L to list, Y to continue or N to exit" 
    switch ($Name){
            "L"{$ADUsers | Select-Object GivenName, Name, SamAccountName, Enabled ;exit}
            "Y"{break; }
            "N"{pause;exit}
    }
}     

foreach($User in $ADUsers){

Write-Host "Found user with SamAccountName: $($User.SamAccountName) and name $($User.Name). Enabled Account Status is set to: $($User.Enabled)" -ForegroundColor Green
$GroupMembership = $User |  Get-ADPrincipalGroupMembership | Select-Object name, GroupScope, distinguishedName | Where-Object {$_.name -like "*$($App)*"}       

$UserExtended = Get-ADUser mattkey -Properties *

        $UserObject = [ordered]@{
            "Name" = $User.Name;
            "SamAccountName" = $UserExtended.SamAccountName
            "Title" = $UserExtended.Title
            "AccountEnabled" = $UserExtended.Enabled
            "StreetAddress" = $UserExtended.StreetAddress
            "EmailAddress" = $UserExtended.EmailAddress
            "TelephoneNumber" = $UserExtended.TelephoneNumber
            }
    
       $userOutput = New-Object -TypeName psobject -Property $UserObject

if($null -ne $GroupMembership){
    $GroupMembership | Out-GridView 
    Write-Host "Full user details are as follows:"
    $userOutput | Format-Table 
}
else{
    Write-Host "The User $($User.SamAccountName) is not member of any groups with the name $($App) `n" -ForegroundColor Green
    }
}
