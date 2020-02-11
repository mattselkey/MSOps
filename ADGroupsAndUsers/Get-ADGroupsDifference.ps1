[CmdletBinding()]
Param(
[Parameter(Mandatory=$true)]
[String]$InputUserOne,
[String]$InputUserTwo


)

$UserOne=((get-aduser $InputUserOne -properties memberof).memberof|get-adobject).name

$UserTwo=((get-aduser $InputUserTwo -properties memberof).memberof|get-adobject).name

Compare-Object -ReferenceObject $UserOne -DifferenceObject $UserTwo -IncludeEqual
