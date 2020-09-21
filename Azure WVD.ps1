Install-Module -Name Microsoft.RDInfra.RDPowerShell
Import-Module -Name Microsoft.RDInfra.RDPowerShell
Add-RdsAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com
$b= Get-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD -AppGroupName "Desktop Application Group"
$b.UserPrincipalName | out-file -FilePath C:\Users\prathmesh\Desktop\INventory\September\RGIWVD.csv
$a = Get-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group"
$a.UserPrincipalName | out-file -FilePath C:\Users\prathmesh\Desktop\INventory\September\RGIWVD-DEVTEAM.csv
$a.count
$a.userprincipalname | Out-File -FilePath C:\Users\prathmesh\Desktop\INventory\September\VDIuserlist.csv
Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName cx

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"  

$properties="redirectdrivers:i:1;audiocapturemode:i:1;camerastoredirect:s:*;audiomode:i:0"
Set-RdsHostPool -TenantName RGI-WVD3 -Name RGIWVD-DEVTEAM -CustomRdpProperty $properties

Get-RdsHostPool
Get-RdsHostPool -TenantName RGI-WVD3 -Name RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group"

Set-RdsHostPool -TenantName RGI-WVD3 -Name RGIWVD1 -CustomRdpProperty $properties
$properties1 = audiomode:i:0;audiocapturemode:i:1;camerastoredirect:s:*;devicestoredirect:s:*;redirectdrivers:i:1;

 RGIWVD1


 Get-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV -AppGroupName "Desktop Application Group" -UserPrincipalName Riyazuddin@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD -AppGroupName "Desktop Application Group" -UserPrincipalName sachins@reliancegeneral.com




 Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV1 -AppGroupName "Desktop Application Group" -UserPrincipalName shilpak@reliancegeneral.com
 Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV1 -AppGroupName "Desktop Application Group" -UserPrincipalName rohitp@reliancegeneral.com
 Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV1 -AppGroupName "Desktop Application Group" -UserPrincipalName LalithaL@reliancegeneral.com
 Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV1 -AppGroupName "Desktop Application Group" -UserPrincipalName sachins@reliancegeneral.com
 Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV1 -AppGroupName "Desktop Application Group" -UserPrincipalName nikhiln@reliancegeneral.com
  #LalithaL@reliancegeneral.com

  
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName shilpak@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName rohitp@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName LalithaL@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName sachins@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName nikhiln@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName LalithaL@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName Vaishnavic@reliancegeneral.com
 Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName sonalir@reliancegeneral.com

  #LalithaL@reliancegeneral.com
  #ShrikantS@reliancegeneral.com


 #############################################################################
 ####Audi vedio command in WVD

 Set-RdsHostPool -TenantName RGI-WVD3 -Name c -CustomRdpProperty $properties10
$properties10 = "audiomode:i:0;audiocapturemode:i:1;camerastoredirect:s:*;devicestoredirect:s:*;redirectclipboard:i:1"

Get-RdsSessionHost -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV
Get-RdsUserSession -TenantName "RGI-WVD3" -HostPoolName RGIWVD-DEV1


Set-RdsHostPool -TenantName RGI-WVD3 -Name RGIWVD-DEV1


$ab = Get-RdsHostPool -TenantName Rgi-WVD3
$ab.hostpoolname
Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEV2 -AppGroupName "Desktop Application Group" -UserPrincipalName Anils@reliancegeneral.com

$name = Get-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group"
$Name.UserPrincipalName | Out-File -FilePath C:\Users\prathmesh\Desktop\INventory\September\VDI\RGIWVD-DEVTEAM.txt
$name.Count

Remove-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group" -UserPrincipalName Vaishnavic@reliancegeneral.com

Add-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-Dev2 -AppGroupName "Desktop Application Group" -UserPrincipalName SUDHAKARC@reliancegeneral.com

$d= Get-RdsAppGroupUser -TenantName RGI-WVD3 -HostPoolName RGIWVD-DEVTEAM -AppGroupName "Desktop Application Group"

$d.userprincipalname


