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
    $ComputerName,
    [Boolean]
    $Now=$true
)

$credentials = Get-Credential

try{
    if($Now){
            Restart-Computer -ComputerName $ComputerName -Credential $credentials -Force
    }else{
            Restart-Computer -ComputerName $ComputerName -Credential $credentials
    }
}
catch{

}

try{
    Test-Connection $ComputerName -Count 20 -Delay 1 -ErrorAction SilentlyContinue
}
catch [System.Net.NetworkInformation.PingException]{

    Write-Error Not repsonding  
    
}