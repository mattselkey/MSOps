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
[CmdletBinding()]
[ValidateSet('ON','OFF')]
Param(
[Parameter(Mandatory=$true)]
[String]$PowerRequestType
)

BEGIN{
$vms = Get-VM | Where-Object {$_.Notes -icontains "Auto"}
}

PROCESS{
ForEach($vm in $vms){

    if($PowerRequestType -eq "ON"){
    Start-VM -Name $vm.Name
    Start-Sleep -s 15
    }
    
    if($PowerRequestType -eq "OFF"){
    
        Stop-VM  -Name $vm.Name
       }
    }
}


END{

}
