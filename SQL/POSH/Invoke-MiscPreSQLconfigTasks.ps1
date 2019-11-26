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
    $SVCAccount,
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


    try{
    $TempLocation = "C:\Temp"
    if(-Not (Test-Path $TempLocation) ){
      Write-Information "Temp work folder missing"
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
    secedit /export /cfg $secPolicyfile /areas user_rights
    Copy-Item -Path $secPolicyfile -Destination $secPolicyTEMPfile

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
    $AccountName,
    [Parameter()]
    [String]
    $LogPath
)
        try{
            Write-Information -MessageData "Policy File is in location: $($PolicyFile)."
            Write-Information -MessageData "TempPolicyFile will be created in location: $($TempPolicyFile)." 
            $line = Get-Content $PolicyFile | Select-String $PolicyName
        
        if($line){
            Write-Information -MessageData "PolicyLine is: $($line)."

        # Use Get-Content to change the text in the cfg file and then save it
        try{
            (Get-Content $PolicyFile).Replace($line,"$line,$AccountName") | Out-File $TempPolicyFile
        }catch{
            Write-Error -Message "Error setting secpolicy, Error is:  $($_)"
        }
        #secedit /configure /db secedit.sdb /cfg C:\secimport.txt /overwrite /areas USER_RIGHTS
        }else{
            Write-Information -MessageData "Policy not found, adding new policy line for : $($PolicyName) to $($TempPolicyFile)."
            Add-Content -Path $TempPolicyFile -Value "$($PolicyName) = $($AccountName)"
        }
    
        secedit /configure /db secedit.sdb /cfg $TempPolicyFile /log "$($Temppathlog)\log.text"

        }catch{
            Write-Error -Message "Error during secpolicy function, Error is:  $($_)"
        }
    }   
}

PROCESS{
    #This doesn't make much sense if we will also add the SQL account to the secpolicy, also consider SOX
    if (-Not(Get-LocalGroupMember -Name "Administrators" -Member $SVCAccount -ErrorAction SilentlyContinue)){
    Add-LocalGroupMember -Group "Administrators"  -Member $SVCAccount
    }

    #set lock memory prviledges
    Set-SecPolicy -PolicyFile $secPolicyfile -TempPolicyFile   $secPolicyTEMPfile -PolicyName "SeLockMemoryPrivilege" -AccountName $SVCAccount -LogPath $TempLocation

    #set lock memory prviledges
     Set-SecPolicy -PolicyFile $secPolicyfile -TempPolicyFile   $secPolicyTEMPfile -PolicyName "SeManageVolumePrivilege" -AccountName $SVCAccount -LogPath $TempLocation
}

END{



}




