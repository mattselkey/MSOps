<#
.SYNOPSIS
    Connect to a remote file server. Close all open files within a given path.
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
    $FileServerName,
    [String]
    $FolderPath,
    [Boolean]
    $VerboseOutput
)

BEGIN{
    $VerbosePreference =  $VerboseOutput
    $sessn = New-CimSession -ComputerName $FileServerName
}


PROCESS{

    $openfiles = Get-SmbOpenFile -CimSession $sessn | Where-Object {$_.Path -like $FolderPath}
    ForEach($openfile in $openfiles ) {
        Write-Verbose  $openfile.ClientUserName 
        }

}

END{


}