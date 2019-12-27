#=================================================================================
# CREATE LOG FILE
# Creates a new log directory and new a log file based on input params
# all scripting logs log output to this file during setup and config
#=================================================================================
function CreateNewLogs{
param ([Parameter(Mandatory = $true)]
			[String]$LogDirectory,
            [String]$LogName,
            [String]$SourceName
		    )
try
     {
     $logFolderName = $LogDirectory
     Write-Host "Creating $($LogName) Log File in $($logFolderName)" -ForegroundColor Green
     $LoggingFilePath =  (New-item ("$logFolderName" + "\$LogName") -type file  -force)
     Logging "INFO" "New Log File Created in $($LoggingFilePath)"
     try{
        Logging "INFO" "Creating new event log called $($SourceName)"
        Logging "INFO" "Checking if EventLog $($SourceName) is already in place."
        $logCheck = Get-EventLog -List

        if(-not ($logCheck.log -ccontains $SourceName)){
            Logging "INFO" "EventLog $($SourceName) not found, creating."
            #New-EventLog [-CategoryResourceFile <String>] [[-ComputerName] <String[]>][-LogName] <String>[-MessageResourceFile <String>][-ParameterResourceFile <String>][-Source] <String
            New-EventLog -Source  $SourceName -LogName $SourceName
        }else{
            Write-Host "EventLog $($LogName) already exists, nothing to do." -ForegroundColor Green  
        }
     }
     Catch [System.InvalidOperationException]{
        New-EventLog -Source  $SourceName -LogName $SourceName
     }
     write-host "This is a test"
    Return  $LoggingFilePath

     }
Catch 
    {
     Write-Host "Error creating $LogName Log File $($_.Exception.ToString())."
    }
}
#End of Function

#=================================================================================
# LOG TO FILE FUNCTION
#=================================================================================
Function Logging{   
param ([Parameter(Mandatory = $true)]
			[string]$Type,
			[string]$logMessagesString
		    )
[String]$currentDT = get-date -format "yyyy-MM-dd HH:mm:ss"
[String]$logMessage =  "$currentDT $Type - $logMessagesString"
Add-Content -Path $LoggingFilePath -Value $logMessage 
if($Type -eq "ERROR"){
    Write-Host $logMessage -ForegroundColor Red
    }
elseif($Type -eq "INFO"){
    Write-Host $logMessage -ForegroundColor Yellow
}
elseif($Type -eq "SUCCESS"){
    Write-Host $logMessage `n -ForegroundColor Green
}
elseif($Type -eq "NOTICE"){
    Write-Host $logMessage -ForegroundColor Cyan
}
elseif($Type -eq "BEGIN"){
    Write-Host $logMessage -ForegroundColor Magenta
}
elseif($Type -eq "COMPLETED"){
    Write-Host $logMessage `n -ForegroundColor Green
}
else{
 Write-Host $logMessage
}

}
#End of Function

Export-ModuleMember -function Logging
Export-ModuleMember -function CreateNewLogs