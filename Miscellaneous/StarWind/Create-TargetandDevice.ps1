Import-Module StarWindX
$server = New-SWServer -host 127.0.0.1 -port 3261 -user root -password starwind

try{

$server.Connect()
New-ImageFile -server $server -path "My Computer\S\Images" -fileName "img2" -Size 10000
$device = Add-ImageDevice -server $server -path "My Computer\S\Images" -fileName "img2" -sectorSize 512 -NumaNode 0
$target = New-Target -server $server -alias "targetimg2" -devices $device.Name


}catch{

Write-Host $_ -ForegroundColor Red

}


Get-Device -server $server