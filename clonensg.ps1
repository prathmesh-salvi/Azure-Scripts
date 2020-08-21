#Connect-AzureRmAccount
#Get-Module -Name *Azurerm*
#name of NSG that you want to copy 
$nsgOrigin = "testVM-nsg" 
#name new NSG  
$nsgDestination = "testVM-nsg_clone" 
#Resource Group Name of source NSG 
$rgName = "NetworkWatcherRG" 
#Resource Group Name when you want the new NSG placed 
$rgNameDest = "Demo" 
 
$nsg = Get-AzureRmNetworkSecurityGroup -Name $nsgOrigin -ResourceGroupName $rgName 
$nsgRules = Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg 
$newNsg = Get-AzureRmNetworkSecurityGroup -name $nsgDestination -ResourceGroupName $rgNameDest 
foreach ($nsgRule in $nsgRules) { 
    Add-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $newNsg ` 
        -Name $nsgRule.Name ` 
        -Protocol $nsgRule.Protocol ` 
        -SourcePortRange $nsgRule.SourcePortRange ` 
        -DestinationPortRange $nsgRule.DestinationPortRange ` 
        -SourceAddressPrefix $nsgRule.SourceAddressPrefix ` 
        -DestinationAddressPrefix $nsgRule.DestinationAddressPrefix ` 
        -Priority $nsgRule.Priority ` 
        -Direction $nsgRule.Direction ` 
        -Access $nsgRule.Access 
} 
Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $newNsg

Get-AzureRmResourceGroup