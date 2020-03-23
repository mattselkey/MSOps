Get-Service adws,kdc,netlogon,dns
Get-WindowsFeature -Name *RSAT* | Install-WindowsFeature