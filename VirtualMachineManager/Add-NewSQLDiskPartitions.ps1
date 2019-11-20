<#
.SYNOPSIS
    Set new partitions online, initiliaze and format
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
    [Parameter(Mandatory=$False)]
    [boolean]$OutInfo=$True
)

BEGIN{

    if($OutInfo){
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Information "messages will be passed to output stream."
    }else{
        $VerbosePreference = "SilentlyContinue"
         $InformationPreference = "SilentlyContinue"
    }

    $ErrorActionPreference = "Stop"

}

PROCESS{
try { 
    Write-Information -Message   "Setting disk to online." 
    Get-Disk | Where-Object {
        $_.OperationalStatus -eq "Offline" 
    } | ForEach-Object { Set-Disk -Number $_.Number -IsOffline $False } 

}
catch 
{
    Write-Error -Message   "Setting disks online failed, error: $($_) " 
}

try { 
    Write-Information -Message   "Initialize disks and format." 
    Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW" } | ForEach-Object { Initialize-Disk -Number $_.Number -PartitionStyle GPT | Out-Null } }
catch 
{
    Write-Error -Message   "Setting disks online failed, error: $($_) " 
}
}

END{


}