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
    $serverName="*"
)


$servers = Get-ADComputer -Filter 'Name -Like "$($serverName)"' | Select-Object dnshostname
#$servers = Get-ADComputer -Filter 'Name -Like "*SUBDN*"' | select dnshostname
$sessionsFound = @()
foreach ($server in $servers.dnshostname){

$currentuser = $env:UserName

try{
     # Write-Information -MessageData "Connnecting to $($server)" -InformationAction Continue
 
     if(Test-Connection $server -Quiet -ErrorAction SilentlyContinue){
      #$SESSIONs =  quser /server:$server 2>> $env:HOMEDRIVE\rdpsessions.txt
     
       try{
          $SESSIONs =  quser /server:$server 2>> $env:HOMEDRIVE\rdpsessions.txt
       }
       catch [System.Management.Automation.RemoteException]{
           throw
       }

       try{
        
        if($SESSIONs){
        #Write-Information -MessageData "Checking sessions on $($server)" -InformationAction Continue
        foreach($SESSION in $SESSIONs){
    
            if($SESSION -like "*$currentuser*"){
                Write-Information -MessageData "found users, session is $($SESSION) on server $($server)" -InformationAction Continue
                $sessionsFound += $server
                }
        }
        }

        }
        catch{
            Write-Information -MessageData "ERROR: Could not check sessions on $($server)  $($_)" -InformationAction Continue
            }

      }
      }
      catch{
        Write-Information -MessageData "ERROR: Could not connect to $($server) $($_)" -InformationAction Continue
      }
}



$sessionsFound = Get-Content "$env:HOMEDRIVE\sessionsFound.txt" | where {$_ -notlike "*000*"}

foreach ($server in $sessionsFound){

        $sessionId = ((quser /server:$server | Where-Object { $_ -match $currentuser }) -split ' +')[2]
        Write-Information -MessageData "Logging off $($sessionId)" -InformationAction Continue

        logoff $sessionId /server:$server

}
