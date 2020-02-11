#====================================================
# Function to get the current script folder root path
# Allows for older version of PowerShell 
#====================================================
Function GetRoothPath{ 

    $Path = $($PWD).Path

    if($null -eq $Path ){
        Write-Host "Path cannot be retrieved via PWD" -ForegroundColor Yellow

        try {

            if($null -ne $MyInvocation.MyCommand.path) {
                Write-Host "Getting path via MyInvocation" -ForegroundColor Green
                $Path =  Split-Path $MyInvocation.MyCommand.path
                
            }
                else
                {
                    Write-Host "Getting path via get-location" -ForegroundColor Green
                    $Path = $(Get-Location).Path ;
                }
        }
        catch {
           Write-Host "Error getting root path. Error is: $($_)" -ForegroundColor Red 
        }

        }
    else {
        Write-Host "Path retried via PWD" -ForegroundColor Green
        }

  return $Path

}
