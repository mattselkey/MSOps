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

#get locally Installed
Write-Information -MessageData "###### Locally installed applications are:" -InformationAction Continue
choco list -local-only
Write-Information -MessageData "-----------------------------------" -InformationAction Continue
Write-Information -MessageData "###### Choco sources are:" -InformationAction Continue
$sources = choco source list
Write-Information -MessageData "-----------------------------------" -InformationAction Continue
foreach($source in $sources){
    #$source.GetType()
    if($source -notcontains "*chocolatey.org*"){
        
        $source


        Write-Information -MessageData "Available packages are:" -InformationAction Continue
        choco source $source
    }

}




