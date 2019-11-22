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
    
    try{
    $TempLocation = "C:\Temp"
    if(-Not (Test-Path $TempLocation) ){
      Write-Information "Temp work folder missing" -InformationAction "Continue"
      New-Item -Path  $TempLocation -ItemType Directory
        } 
    }catch{

        Write-Error  "Error creating/checking temp work folder $($_)"
    }

    $SVCAccount

    # Set a name for the Security Policy cfg file.
    $secPolicyfile = "$TempLocation\SecPolExport.cfg"
    $secPolicyTEMPfile = "$TempLocation\TEMPSecPolExport.cfg"

    #export currect Security Policy config
    Write-Information "Exporting Security Policy to file"
    secedit /export /cfg $secPolicyfile

function Set-SecPolicy{
[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $PolicyFile,
    [Parameter()]
    [String]
    $TempPolicyFile,
    [Parameter()]
    [String]
    $PolicyName,
    [Parameter()]
    [String]
    $AccountName
)
        try{
        Write-Information -MessageData "PolicyFile is in location: $($PolicyFile)." -InformationAction "Continue"
        Write-Information -MessageData "TempPolicyFile will be created in location: $($TempPolicyFile)." -InformationAction "Continue"
        $line = Get-Content $PolicyFile | Select-String $PolicyName
        
        if($line){
        Write-Information -MessageData "PolicyLine is: $($line)." -InformationAction "Continue"

        # Use Get-Content to change the text in the cfg file and then save it
        try{
        (Get-Content $PolicyFile).Replace($line,"$line,$AccountName") | Out-File $TempPolicyFile
        }catch{
            Write-Error -Message "Error setting secpolicy, Error is:  $($_)"

        }
        #secedit /configure /db secedit.sdb /cfg C:\secimport.txt /overwrite /areas USER_RIGHTS
        }else{
        Write-Information -MessageData "PolicyLine not found, adding new poliy line for : $($PolicyName)." -InformationAction "Continue"
        Add-Content $TempPolicyFile "`n$($PolicyName) = $($SQLServiceAccount)"
        }
        
        
        
        secedit /configure /db secedit.sdb /cfg $TempPolicyFile 1> $null

        }catch{
            Write-Error -Message "Error during secpolicy function, Error is:  $($_)"
        }
    }
    
}

PROCESS{
    #This doesn't make much sense if we will also add the SQL account to the secpolicy, also consider SOX
    if (-Not(Get-LocalGroupMember -Name "Administrators" -Member $SVCAccount)){
    Add-LocalGroupMember -Group "Administrators"  -Member $SVCAccount
    }

    #set lock memory prviledges
    Set-SecPolicy -PolicyFile $secPolicyfile -TempPolicyFile   $secPolicyTEMPfile -PolicyName "SeLockMemoryPrivilege" -AccountName $SVCAccount

    #set lock memory prviledges
    Set-SecPolicy -PolicyFile $secPolicyfile -TempPolicyFile   $secPolicyTEMPfile -PolicyName "SeManageVolumePrivilege" -AccountName $SVCAccount



}

END{



}



