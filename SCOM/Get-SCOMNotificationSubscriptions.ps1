<#
.SYNOPSIS
    This script outputs a grid view of SCOM Notifications with related subscriber and channel information.
.DESCRIPTION
    This script combines SCOM Notiifcations, subscribers and channel informaiton to give a clear overview of which users are contacted and
    also which smtp addresses are used.
.EXAMPLE
    PS C:\>.\Get-SCOMNotificationSubscriptions.ps1 -ManagementServerName SERVERNAME.
    Where ManagementServerName is the of your SCOM management server.
.INPUTS
    SCOM Management Server Name.
.OUTPUTS
    Report as GridView.
.NOTES
    The mininum requirement is SCOM management cmdlets must be installed locally.
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[String]$ManagementServerName,
[Parameter(Mandatory=$false,ValueFromPipeline=$true)]
[String]$Recipient = "*"
)

$SCOMnotificationSubs = Get-SCOMNotificationSubscription -ComputerName $ManagementServerName  | Select-Object Displayname, ToRecipients
$pagerSubs = @()
foreach ($SCOMnotificationSub in $SCOMnotificationSubs)
{ 
foreach($recipe in $SCOMnotificationSub.ToRecipients){

    if($recipe.Name -like "*$($Recipient)*") 
        {
        $pagerSubs += $SCOMnotificationSub
        }
    }
}

$OutGrid = @()
foreach ($pagerSub in $pagerSubs){
$OutGrid += Get-SCOMNotificationSubscription -ComputerName $ManagementServerName -DisplayName $pagerSub.DisplayName | Select-Object DisplayName, Description, Enabled,
@{label="SubscriberAddresses";
Expression={$pagerSub.ToRecipients | 
        ForEach-Object { 
            Get-SCOMNotificationSubscriber -ComputerName $ManagementServerName -Name $_.Name | 
                    ForEach-Object {$_.devices | Where-Object {$_.protocol -eq "smtp"}} | 
                        ForEach-Object {
                                $_.Address
                }
          }
     }
},
@{label="AlertScheduleDays";
Expression={
            $pagerSub.ToRecipients | 
             ForEach-Object { 
                    Get-SCOMNotificationSubscriber -ComputerName $ManagementServerName -Name $_.Name |
                        ForEach-Object {$_.Devices | Where-Object {  $_.ScheduleEntries -ne $null} | Select-Object ScheduleEntries   |
                                ForEach-Object{
                                        #$_.DailyStartTime
                                        $($_.ScheduleEntries).ScheduledDays 
                }     
           }
     }
  }
},
@{label="AlertScheduleTime";
Expression={
            $pagerSub.ToRecipients | 
             ForEach-Object { 
                    Get-SCOMNotificationSubscriber -ComputerName $ManagementServerName -Name $_.Name |
                        ForEach-Object {$_.Devices | Where-Object {  $_.ScheduleEntries -ne $null} | Select-Object ScheduleEntries   |
                                ForEach-Object{
                                        #$_.DailyStartTime
                                        "StartTime:$($($($_.ScheduleEntries).DailyStartTime).Hour):$($($($_.ScheduleEntries).DailyStartTime).Minute) " +`
                                        "EndTime:$($($($_.ScheduleEntries).DailyEndTime).Hour):$($($($_.ScheduleEntries).DailyEndTime).Minute)"
                            } 
                       }
               }
         }
    }

}
$OutGrid | Out-GridView 