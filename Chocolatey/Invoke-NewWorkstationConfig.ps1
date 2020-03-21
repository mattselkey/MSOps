Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install googlechrome 
choco install visualstudiocode
choco install googlechrome

choco install notepadplusplus



iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"