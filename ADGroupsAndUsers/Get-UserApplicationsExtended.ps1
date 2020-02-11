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
[String]$App = "*",
[Parameter(Mandatory=$false)]
[String]$Domain = "$env:USERDNSDOMAIN",
[Parameter(Mandatory=$false)]
[String]$VerboseOutput

)

function get-adUserbyname{
        Param(
            [Parameter(Mandatory)]
            [String]$NameFilter,
            [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
            [String]$Domain = "$env:USERDNSDOMAIN"
            )

        $NameFilter = 'name -like "*' + $($Name) +'*"'
        $ADUsers =  Get-ADUser -Filter $NameFilter -Server $Domain
        if ($null -eq $ADUsers){
            try{
                $ADUsers =  Get-ADUser $Name -Server $Domain  
            }
            catch{
                Write-Verbose "User not found. $($_)"
            }
        }
        return  $ADUsers
}

function get-adUserByDomain{




}

$VerbosePreference =  $VerboseOutput
$ADUsers = get-adUserbyname $Name

 while ($NULL -eq $ADUsers) {
        Write-Output "User not found"
        $choice = Read-Host "Input user name (N) or try another Domain (D), or Exit (E)"
        switch ($choice){
                        "N"{$ADUsers = get-adUserbyname -NameFilter $Name}
                        "D"{
                            $Domain  = Read-Host "Enter Domain name"                          
                            
                            $ADUsers = get-adUserbyname -NameFilter $Name -Domain $Domain 
                        }
                         "E"{
                             Pause
                             exit   
                         }   
                    }
        
    }

if($ADUsers.count -gt 1){

    Write-Output "$($ADUsers.count) Users have been found, do you want to continue?"
    $Name = Read-Host "Type L to list, Y to continue or N to exit" 
    switch ($Name){
            "L"{$ADUsers  | Select-Object GivenName, Name, SamAccountName, Enabled | Sort-Object -Property GivenName ;exit}
            "Y"{break; }
            "N"{pause;exit}
    }
}     

foreach($User in $ADUsers){
 Write-Host   $User -ForegroundColor Green
Write-Output "Found user in domain $($Domain) with SamAccountName: $($User.SamAccountName) and name $($User.Name). Enabled Account Status is set to: $($User.Enabled)"
try{
$GroupMembership = $User |  Get-ADPrincipalGroupMembership -Server $Domain | Select-Object name, GroupScope, distinguishedName | Where-Object {$_.name -like "*$($App)*"}       
}
catch{
Write-Verbose Error occurred
}

$UserExtended = Get-ADUser $User -Properties *

        $UserObject = [ordered]@{
            "Name" = $User.Name;
            "SamAccountName" = $UserExtended.SamAccountName
            "LastLogonDate" = $UserExtended.LastLogondate
            "Title" = $UserExtended.Title
            "AccountEnabled" = $UserExtended.Enabled
            "StreetAddress" = $UserExtended.StreetAddress
            "PostalCode" = $UserExtended.PostalCode
            "City" = $UserExtended.City
            "Country" = $UserExtended.co
            "EmailAddress" = $UserExtended.EmailAddress
            "TelephoneNumber" = $UserExtended.TelephoneNumber
            "Fax" = $UserExtended.Fax
            "Manager" = $UserExtended.Manager
            }
    
       $userOutput = New-Object -TypeName psobject -Property $UserObject
if($null -ne $GroupMembership){
    $GroupMembership | Out-GridView 
    Write-Output "Full user details are as follows:"
    $userOutput 
}
else{
    Write-Error "The User $($User.SamAccountName) is not member of any groups with the name $($App)"
    }
}
