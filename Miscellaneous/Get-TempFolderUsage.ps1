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
Param(
[Parameter(Mandatory=$true)]
[String]$FolderName
)


$tempfolders = (Get-ItemProperty  "C:\Users\*\Appdata\Local\Temp\" | Select-Object -ExpandProperty FullName)

$tempfolders.Count

foreach($tempfolder in $tempfolders){
try{

$Size = (Get-ChildItem -Path $tempfolder -Recurse -File | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue)
 
$Total = "{0:N2} GB" -f ($Size.Sum/1GB)
}
catch{}

Write-Host Folder is: $tempfolder 
write-host Size is: $Total

}