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
    $SVCAccount
)

BEGIN{

    $TempLocation = "C:\Temp"
    $SQLServiceAccount = $SVCAccount

    # Set a name for the Security Policy cfg file.
    $fileName = "$TempLocation\SecPolExport.cfg"

    #export currect Security Policy config
    Write-Information "Exporting Security Policy to file"
    secedit /export /cfg $filename

function Set-SecPolicy{
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $PolicyFile,
    [Parameter()]
    [String]
    $PolicyName,
    [Parameter()]
    [String]
    $AccountName
)
        $line = Get-Content $fileName | Select-String $PolicyName
        # Use Get-Content to change the text in the cfg file and then save it
        (Get-Content C:\secexport.txt).Replace($line,"$line,$AccountName") | Out-File $fileName

        #secedit /configure /db secedit.sdb /cfg C:\secimport.txt /overwrite /areas USER_RIGHTS
        secedit /configure /db secedit.sdb /cfg $fileName 1> $null

}


}

PROCESS{
    #This doesn't make much sense if we will also add the SQL account to the secpolicy, also consider SOX
    Add-LocalGroupMember -Group "Administrators"  -Member $SQLServiceAccount

    #set lock memory prviledges
    Set-SecPolicy -PolicyFile $filename -PolicyName "SeLockMemoryPrivilege" -AccountName $SQLServiceAccount

    #set lock memory prviledges
    Set-SecPolicy -PolicyFile $filename -PolicyName "SeManageVolumePrivilege" -AccountName $SQLServiceAccount



}

END{



}



