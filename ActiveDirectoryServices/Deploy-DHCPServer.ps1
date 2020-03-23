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

#Uninstall-WindowsFeature DHCP -Remove

$checkDHCPService = Get-windowsfeature -Name DHCP   

if($checkDHCPService){

}
else{
Install-WindowsFeature DHCP -IncludeManagementTools
$checkDHCPService = Get-windowsfeature -Name DHCP 
}

#Install windows features
try {
    if ($checkDHCPService.InstallState -ne "Installed"){
    
    Write-Information -MessageData "Installing DHCP services and management tools"
    
    Install-WindowsFeature DHCP -IncludeManagementTools
    
        }
    }catch{
    
    Write-Debug -Message "Error installing DHCP services. Error is $($_)"
    
    exit
    
    }

$serverFQDN = [System.Net.Dns]::GetHostByName($env:computerName)

Add-DhcpServerInDC -DnsName $serverFQDN.HostName  -IPAddress $serverFQDN.AddressList.IPAddressToString


Add-DhcpServerV4Scope -Name "Lab Scope" -StartRange 192.168.4.1 -EndRange 192.168.1.254 -SubnetMask 255.255.255.0 -LeaseDuration 8:00:00


Add-DhcpServerv4PolicyIPRange -ScopeId 192.168.4.0 -Name "Lab Scope" -StartRange 192.168.4.1 -EndRange 192.168.1.254

Set-DhcpServerV4OptionValue -DnsServer 192.168.4.10 -Router 192.168.4.1

Set-DhcpServerv4Scope 
Add-DhcpServerv6ExclusionRange -StartRange 192.168.4.1 -EndRange 192.168.4.200 -Prefix

Restart-service dhcpserver