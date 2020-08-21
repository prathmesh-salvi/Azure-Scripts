#######################################################################
#### This Script is to Allow\Block IP on multiple VM's NSG
##############################################################################################################################################
#Set the variable  
$RULE_NAME = Read-Host "Enter the Name of Rule"
$DIRECTION = Read-Host "Enter the Inbound or Outound"
$PRIORITY = Read-Host "set the Priority and it should above 100 "
$ACCESS_Type = Read-Host "Enter the Access type to Allow or Deny "
$SOURCEADDRESSPREFIX = Read-host 'Enter Source Address ip Range'
$SOURCEPORTRANGE = Read-host 'Enter source port'
$DESTINATIONADDRESSPREFIX = Read-host 'Enter Destination Address ip Range '
$DESTINATIONPORTRANGE = Read-host 'Enter Destination Port range'
$PROTOCOL = Read-host 'Enter the Protocall *, TCP , UDP, ICMP '
$DESCRIPTION = Read-host 'Enter the Description'

##############################################################################################################################################
$GETNSG = Get-AzNetworkSecurityGroup
$NSG= $GETNSG| foreach-object { 
    [PSCustomObject]@{
    "NSG_name" = $_.Name
    "NSG`_REsourceGroup" = $_.ResourceGroupName
    "NSG_location" = $_.Location
     }}

foreach ($nsgs in $NSG)
{
#$NSGs
$NSGRule= Get-AzNetworkSecurityGroup -Name $NSGs.NSG_name -ResourceGroupName $NSGS.NSG_REsourceGroup 

$NSGRule = Add-AzNetworkSecurityRuleConfig -Name $RULE_NAME `
                -Direction $DIRECTION `
                -Priority $PRIORITY `
                -Access $ACCESS_Type `
                -SourceAddressPrefix $SOURCEADDRESSPREFIX `
                -SourcePortRange $SOURCEPORTRANGE `
                -DestinationAddressPrefix $DESTINATIONADDRESSPREFIX `
                -DestinationPortRange $DESTINATIONPORTRANGE `
                -Protocol $PROTOCOL `
                -Description $DESCRIPTION `
                -NetworkSecurityGroup $NSGRule


# Update the NSG.
$NSGRUle | Set-AzNetworkSecurityGroup
}
 