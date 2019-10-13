<#
.SYNOPSIS
    Power manage Hyper-V VMs
.DESCRIPTION
    Starts or Shutsdown any VM with "x:Auto" within the VMs notes. Wait 15s seconds between each VMs boot.
    where x is the order the VM should be powered on and Auto confirms the machine should be power managed by the script.
.EXAMPLE
    PS C:\>.\Invoke-VMPowerManage.ps1 -PowerRequestType ON

    PS C:\>.\Invoke-VMPowerManage.ps1 -PowerRequestType OFF
.INPUTS
    
.OUTPUTS
   
.NOTES
   
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[ValidateSet('ON','OFF')]
[String]$PowerRequestType
)

BEGIN{
$vms = Get-VM | Select-Object Name, Notes | Where-Object {$_.Notes -match ":Auto"}
}

PROCESS{

    foreach($vm in $vms){
        $vm.Notes = [Convert]::ToInt32($($vm.Notes).Trim(":Auto"))
        }
    

    if($PowerRequestType -eq "ON"){
        $vms | Sort-Object -Property Notes | ForEach-Object    {
        Write-Output "$($_.Notes) Starting VM $($_.Name)"
        Start-VM -Name $_.Name
        Start-Sleep -s 15
        }
    }
    
    
    if($PowerRequestType -eq "OFF"){
        $vms | Sort-Object -Property Notes -Descending | ForEach-Object    {  
        Write-Output "$($_.Notes) Shutting down VM $($_.Name)"
        Stop-VM  -Name $_.Name
        }
    }
}


END{

}
