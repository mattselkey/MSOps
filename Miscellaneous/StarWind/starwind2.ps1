param($addr="127.0.0.1", $port=3261, $user="root", $password="starwind", $deviceName="imagefile1", $extendSize=100000)

#
# The following example shows how to extend Image File device. 
# LSFS and HA device also support extend feature. 
#
Import-Module StarWindX

try
{
	Enable-SWXLog

	$server = New-SWServer $addr $port $user $password

	$server.Connect()

	$device = Get-Device $server -name $deviceName
	if( !$device )
	{
		Write-Host "Device not found" -foreground red
		return
	}

	$device.ExtendDevice($extendSize) # Specify the amount of disk space you want to add to the virtual disk volume.
}
catch
{
	Write-Host $_ -foreground red
}
finally
{
	$server.Disconnect()
}