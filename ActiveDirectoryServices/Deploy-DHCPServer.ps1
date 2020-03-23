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

$checkDHCPService = Get-windowsfeature -Name DHCP   

if($checkDHCPService){

}
else{
Install-WindowsFeature DHCP -IncludeManagementTools
}


Add-DhcpServerV4Scope -Name "Lab Scope" -StartRange 192.168.4.200 -EndRange 192.168.1.225 -SubnetMask 255.255.255.0
Set-DhcpServerV4OptionValue -DnsServer 192.168.4.10 -Router 192.168.4.1
Set-DhcpServerv4Scope -ScopeId 192.168.1.10 -LeaseDuration 1.00:00:00
Restart-service dhcpserver