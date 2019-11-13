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
    [String]$SCOMServerName,
    [Parameter()]
    [String]$Name,
    [Parameter()]
    [String]$SMTPServerAddress="",
    [Parameter()]
    [UInt32]$port="587",
    [Parameter()]
    [String]$fromAddress="xxx@xxx.com"

)

BEGIN{

    $subject = "$Data[Default='Not Present']/Context/DataItem/ManagedEntityPath$/$Data[Default='Pager']/Context/DataItem/AlertName$"

    $Body = "Alert: $Data[Default='Not Present']/Context/DataItem/AlertName$" +
    "Source: $Data[Default='Not Present']/Context/DataItem/ManagedEntityDisplayName$" +
    "Last modified by: $Data[Default='Not Present']/Context/DataItem/LastModifiedBy$" +
    "Last modified time: $Data[Default='Not Present']/Context/DataItem/LastModifiedLocal$" +
    "Alert description: $Data[Default='Not Present']/Context/DataItem/AlertDescription$" +
    "Alert view link:" + "$Target/Property[Type=" + "Notification!Microsoft.SystemCenter.AlertNotificationSubscriptionServer" + 
    "]/WebConsoleUrl$?DisplayMode=Pivot&AlertID=$UrlEncodeData/Context/DataItem/AlertId$"

}

PROCESS{

try{
 
$check = Get-SCOMNotificationChannel -Computer $SCOMServerName -DisplayName $Name -ErrorAction SilentlyContinue

if(!$check){

Add-SCOMNotificationChannel -Computer $SCOMServerName -DisplayName $Name  -Name $Name -Server $SMTPServerAddress -Port $port -From $fromAddress -Subject $Subject -Body $Body
}else{

Write-Information -MessageData "This Notification channel already Exists" -InformationAction Continue

}

}
catch{

Write-Error -Message "Failed ($_)"

}


}

END{



}