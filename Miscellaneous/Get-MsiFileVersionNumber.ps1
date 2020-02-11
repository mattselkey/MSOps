<#
.SYNOPSIS
    return the build version number of an MSI file
.DESCRIPTION
    
.EXAMPLE
    PS C:\>.\Get-MsiFileVersionNumber.ps1 C:\test\ActiveBatchX86.msi
    
.INPUTS
    full path and file name
.OUTPUTS
    file build version number
.NOTES
    Taken from  http://stackoverflow.com/q/8743122/383673 with minor modifications
#>
[CmdletBinding()]
param (
    [Parameter()]
    [IO.FileInfo] $MSI
)
BEGIN{

    if (!(Test-Path $MSI.FullName)) {
        throw "File '{0}' does not exist" -f $MSI.FullName
    }


}

PROCESS{
try {
    $windowsInstaller = New-Object -com WindowsInstaller.Installer
    $database = $windowsInstaller.GetType().InvokeMember(
        "OpenDatabase", "InvokeMethod", $Null,
        $windowsInstaller, @($MSI.FullName, 0)
    )
 
    $q = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
    $View = $database.GetType().InvokeMember(
        "OpenView", "InvokeMethod", $Null, $database, ($q)
    )
 
    $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
    $record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
    $version = $record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $record, 1 )
 
    return $version
} catch {
    throw "Failed to get MSI file version: {0}." -f $_
}

}

END{}