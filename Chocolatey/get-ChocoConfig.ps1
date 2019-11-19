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
    $noisy=$False
)

begin{

if($noisy){
    $output = "Continue"
}
else{
    $output = "SilentlyContinue"
}


}

process {
#get locally Installed
Write-Information -MessageData "###### Locally installed applications are:" -InformationAction $output
choco list -local-only
Write-Information -MessageData "----------------------------------------------------------------------" -InformationAction $output
Write-Information -MessageData "###### Choco sources are:" -InformationAction $output
[String[]]$sources = choco source list
#$sources.Count
foreach($source in $sources){
    #$source.GetType()
    if((($source -notmatch "^(Chocolatey)") -or ($source -notmatch  "^(chocolatey)"))  ){
        Write-Information -MessageData "----------------------------------------------------------------------" -InformationAction $output
        Write-Information -MessageData "Found source $($source)" -InformationAction $output
        $internalSource = ($source.split(" https")[0]).TrimEnd(" -")

        Write-Information -MessageData "From source $($internalSource) Available packages are:" -InformationAction $output
        choco list --source $internalSource
    }

}

}

end{




}



