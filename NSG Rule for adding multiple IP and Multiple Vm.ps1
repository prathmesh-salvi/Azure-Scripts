#Connect-AzAccount
#######################################################################
#### This Script is to Allow\Block IP on multiple VM's NSG
##############################################################################################################################################
#Set the variable  
$RULE_NAME = "Outbound_SPAM_IP_Blocked"
$DIRECTION = "Outbound"
$PRIORITY = "550"
$ACCESS_Type = "Deny"
$SOURCEADDRESSPREFIX = @("120.53.124.104/32","69.197.159.82/32")
$SOURCEPORTRANGE = "*"
$DESTINATIONADDRESSPREFIX = "*"
$DESTINATIONPORTRANGE = "*"
$PROTOCOL = "*"
$DESCRIPTION = "$SOURCEADDRESSPREFIX is blocked INC-582025,INC-581611"

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
