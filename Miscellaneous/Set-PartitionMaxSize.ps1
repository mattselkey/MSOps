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
    [Parameter(Mandatory=$True)]
    [String]
    $MachineName,
    [Parameter(Mandatory=$False)]
    [String]
    $DriveLetter="C",
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
}

PROCESS{

try{
    Write-Information -MessageData "Requesting credentials for remote session"
    $credentials = Get-Credential

    Write-Information -MessageData "Connecting to remote machine"
    $cimSession = New-CimSession -ComputerName $MachineName -Credential $credentials

    Write-Information -MessageData "Getting partition named $($DriveLetter)"
    $partition = Get-Partition -CimSession $cimSession | Where-Object {$_.DriveLetter  -eq $DriveLetter}
    
    $currentPartitionSize = "{0:N2} GB" -f (($partition.Size)/1GB)   
    $diskNumber = $partition.DiskNumber
    $partitonNumber = $partition.PartitionNumber

    Write-Information -MessageData "Disknumber is $($diskNumber) and Parition Number is $($partitonNumber)."
    Write-Information -MessageData "Current Partition Size is: $($currentPartitionSize)."

    Write-Information -MessageData "Getting Partiton Supported Size."
    $size  = Get-PartitionSupportedSize -CimSession $cimSession -DriveLetter $DriveLetter

    Write-Information -MessageData "Resizing Partititon."
    Resize-Partition -CimSession $cimSession -DiskNumber $diskNumber -PartitionNumber $partitonNumber -Size $size.SizeMax


    
    $updatedPartiton = Get-Partition -CimSession $cimSession -DriveLetter $DriveLetter
    $updatedPartitonSize = "{0:N2} GB" -f (($updatedPartiton.Size)/1GB)

    Write-Information -MessageData "Previous partiton size was $($currentPartitionSize), New partition size is $($updatedPartitonSize)"

}catch{
    Write-Error "Resize failed ($_)"
}

}

END {
    Write-Information -MessageData "Closing cimsession."
    Remove-CimSession -CimSession $cimSession 

}