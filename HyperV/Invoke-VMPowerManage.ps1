<#
.SYNOPSIS
    Power manage Hyper-V VMs
.DESCRIPTION
    Start any VM with "Auto" within the VMs notes. Wait 15s seconds between each VMs boot.
.EXAMPLE
    PS C:\>.\Invoke-VMPowerManage.ps1
.INPUTS
    
.OUTPUTS
   
.NOTES
   
#>

$vms = Get-VM | Where-Object {$_.Notes -icontains "Auto"}

ForEach($vm in $vms){
Start-VM -Name $vm.Name
Start-Sleep -s 15
}