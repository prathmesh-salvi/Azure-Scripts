#Connect-AzAccount

$NameVM = "MyVm3"
$NewVmname = "MyVm3"
$oldRG = "AZ-DEMO"
$newVmVnet = "TESTmigrate"
$newvmsubnet = "SUB"
$newvmRG = "test"
$DNSIP ="192.168.1.4"
$BootDiagSA = "aztestmigrate111"
$oldNSG = "MyVm3-nsg"
$location = "East US 2"

try{
#########################################################################################################################################################################
##### Get Vm details before Migration to new Vnet and Resource Group
#########################################################################################################################################################################

$VMs = Get-AzVM -Name $NameVM
$vmOutput1= $VMs | ForEach-Object { 
    [PSCustomObject]@{
        "VM_Name" = $_.Name
        "VM_hostname" = $_.OSProfile.ComputerName  
        "VM_Type" = $_.StorageProfile.osDisk.osType
        "VM_OS Version" = $_.StorageProfile.ImageReference.Sku
        "VM_types" = $_.HardwareProfile.VmSize
        "Vm_Os_diskname" = $_.StorageProfile.OsDisk.Name
        "VM_Os_Disk Size" = $_.StorageProfile.OsDisk.DiskSizeGB
        "VM_Os_Sisk_Id"   = $_.StorageProfile.OsDisk.ManagedDisk.Id
        "VM_Data_Disk_Size " = ($_.StorageProfile.DataDisks.DiskSizeGB)
        "VM_data_Disk_name" = $_.StorageProfile.DataDisks.name
        "VM_Data_Disk_Id" = $_.StorageProfile.DataDisks
        "Vm_NIc" = $_.NetworkProfile.NetworkInterfaces
        "Vm_Resourcegroup" = $_.ResourceGroupName
        "Vm_location" = $_.Location
        "Vmid" = $_.VmId
        "DiagnosticsProfile" = $_.DiagnosticsProfile.BootDiagnostics.StorageUri           
    }
}

#########################################################################################################################################################################
##### Sending output of VM and it's REsources to Temp folder before Migration
#########################################################################################################################################################################
$vmOutput1.VM_Name
$vmOutput1 | Out-File c:\temp\VM_Resources_details_before_migration.txt
    
#########################################################################################################################################################################
##### Creating Snapshot of Disk in NEW Resource Group
#########################################################################################################################################################################

$vm = get-azvm -Name $NameVM -ResourceGroupName $oldRG
##############################################
#### Creating Os Disk Snapshot of VM #########
##############################################
   
    write-Output "VM $($vm.name) OS Disk Snapshot Begin `n"
    $snapshotdisk = $vm.StorageProfile
    
        $OSDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $snapshotdisk.OsDisk.ManagedDisk.id -CreateOption Copy -Location "$location"
        $snapshotNameOS = "$($snapshotdisk.OsDisk.Name)_snapshot_$(Get-Date -Format ddMMyy)"

        # OS Disk Snapshot

            try {
                New-AzSnapshot -ResourceGroupName $newvmRG -SnapshotName $snapshotNameOS -Snapshot $OSDiskSnapshotConfig -ErrorAction Stop
            } catch {
                $_
            }
    
            Write-Output "VM $($vm.name) OS Disk Snapshot End `n"

#######################################################################
######## Create OS Disk from snapshot #################################
#######################################################################
Write-Output "VM $($vm.name) OS Disk Creation Start `n"
$Snapshot_os_Name = $snapshotNameOS
$SnapshotResourceGroup = "$newvmRG"
$DiskNameOS = "$($NameVM)_Osdisk"
$Snapshot_Data_DISK = "$snapshotNameData"
$DataDiskName = "$($NameVM)_datadisk"

$snapshot_os_Diskinfo = Get-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName $Snapshot_os_Name
$diskType = Get-AzDisk -ResourceGroupName $snapshotdisk.OsDisk.ManagedDisk.id.Split("/")[4] -DiskName $snapshotdisk.OsDisk.ManagedDisk.id.Split("/")[8]

New-AzDisk -DiskName $DiskNameOS (New-AzDiskConfig  -Location "$location" -CreateOption Copy -SourceResourceId $snapshot_os_Diskinfo.Id -SkuName $diskType.Sku.Name) -ResourceGroupName $SnapshotResourceGroup 

Write-Output "VM $($vm.name) OS Disk Creation End `n"

########################################################
#### Creating Data Disk Snapshots and Disksof VM #######
########################################################

    Write-Output "VM $($vm.name) Data Disk Snapshots and Disk Creation Begin `n"

    $dataDisks = ($snapshotdisk.DataDisks).name

        foreach ($datadisk in $datadisks) {

            $dataDisk = Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $datadisk

            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Snapshot Begin `n"

            $DataDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $dataDisk.Id -CreateOption Copy -Location "$location"
            $snapshotNameData = "$($datadisk.name)_snapshot_$(Get-Date -Format ddMMyy)"

            $snapshot = New-AzSnapshot -ResourceGroupName $newvmRG -SnapshotName $snapshotNameData -Snapshot $DataDiskSnapshotConfig -ErrorAction Stop
         
            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Snapshot End `n"
            
            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Disk Begin `n"
            $datadiskconfig =  New-AzDiskConfig  -Location "$location" -CreateOption Copy -SourceResourceId $snapshot.Id -SkuName $dataDisk.Sku.Name
            New-AzDisk -DiskName $dataDisk.name -ResourceGroupName $newvmRG -Disk $datadiskconfig   
            Write-Output "VM $($vm.name) data Disk $($datadisk.Name) Disk End `n" 
        }

    Write-Output "VM $($vm.name) Data Disk Snapshotsand Disk creation End `n" 

##########################################################################################################################################################################################################
######## Creating network interface
##########################################################################################################################################################################################################

Write-Host "Network Interface Creation Start `n"
$Subnet = Get-AzVirtualNetwork -Name "$newVmVnet" -ResourceGroupName "$newvmRG"
$NetInterface = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
if($NetInterface.NetworkSecurityGroup -eq $null){
    $NewNIC =New-AzNetworkInterface -Name "$($NewVmname)_Nic1" -ResourceGroupName $Subnet.ResourceGroupName -Location $Subnet.Location -SubnetId $Subnet.Subnets[0].Id -DnsServer "$DNSIP"
}
else{
    $NewNIC =New-AzNetworkInterface -Name "$($NewVmname)_Nic1" -ResourceGroupName $Subnet.ResourceGroupName -Location $Subnet.Location -SubnetId $Subnet.Subnets[0].Id -DnsServer "$DNSIP" -NetworkSecurityGroupId $NetInterface.NetworkSecurityGroup.Id
    
    if($NetInterface.NetworkSecurityGroup.Id.Split("/")[4] -ne $newvmRG){
        Write-Host "Network Security Group Migration Start `n"
        $NSG = Get-AzResource -ResourceGroupName $oldRG -ResourceName $oldNSG
        Move-AzResource -DestinationResourceGroupName $newvmRG -ResourceId $NSG.ResourceId -Force
        Write-Host "Network Security Group Migration End `n"
    }
}
Write-Host "Network Interface Creation End `n"

#####################################################################################################################################################################################
########  Creating Disk Config for New Vm
#####################################################################################################################################################################################


Write-Host "VM Configuration Start `n"
$vmosdisk = Get-AzDisk -DiskName $DiskNameOS -ResourceGroupName $newvmRG

#Initialize virtual machine configuration
$NewVMConfig = New-AzVMConfig -VMName $NewVmname -VMSize $VMs.HardwareProfile.VmSize

#Use the Managed Disk Resource Id to attach it to the virtual machine. Please change the OS type to linux if OS disk has linux OS
$NewVMConfig = Set-AzVMOSDisk -VM $NewVMConfig -ManagedDiskId $vmosdisk.Id -CreateOption Attach -Windows

Set-AzVMBootDiagnostic -VM $NewVMConfig -Enable -StorageAccountName $BootDiagSA -ResourceGroupName $newvmRG

$NewVMConfig = Add-AzVMNetworkInterface -VM $NewVMConfig -NetworkInterface $NewNic

Write-Host "VM Configuration End `n"
#Write-Output -InputObject "Removing old virtual machine"
#Remove-AzVM -Name $NameVM -ResourceGroupName $oldRG -Force

Write-Host "VM Creation Start `n"
#Create the virtual machine with Managed Disk
New-AzVM -VM $NewVMConfig -ResourceGroupName $newvmRG -Location $vms.Location
Write-Host "VM Creation End `n"

Get-Azvm

}
catch
{
    Write-Host "Exception: ", $_.Exception.Message
}


#######################################################################################################################################################################
####### Adding Data Disk To new Vm
#######################################################################################################################################################################
$dataDisks
$luncount = $dataDisks.Count

foreach($adddatadisk in $dataDisks){
for($lun1 = 1; $lun1 -le $luncount ; $lun1++)

{ 
$getdisk = Get-AzDisk -ResourceGroupName $newvmRG -DiskName $adddatadisk

$GETNEWVM = Get-AzVM -Name $NewVmname -ResourceGroupName $newvmRG

$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -VM $GETNEWVM  -ManagedDiskId $getdisk.Id -Name $getdisk.Name -Lun $lun1

#$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $GETNEWVM  -ManagedDiskId $getdisk.Id

Update-AzVM -VM $GETNEWVM -ResourceGroupName $newvmRG -ErrorAction Ignore}
}


#######################################################################################################################################################################
####### Enable hybrid licence
#######################################################################################################################################################################

$VMlicence = Get-AzVM -ResourceGroup "$newvmRG" -Name "$NewVmname"
$VMlicence.LicenseType = "Windows_Server"
Update-AzVM -ResourceGroupName "$newvmRG" -VM $vmlicence




#######################################################################################################################################################################################

$rgName = "myResourceGroup"
$vmName = "myVM"
$location = "East US" 
$dataDiskName = "myDisk"
$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $dataDiskName 

$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName 

$vm = Add-AzVMDataDisk -CreateOption Attach -Lun 0 -VM $vm -ManagedDiskId $disk.Id

Update-AzVM -VM $vm -ResourceGroupName $rgName




$dataDisks
foreach($adddatadisk in $dataDisks){

$getdisk = Get-AzDisk -ResourceGroupName $newvmRG -DiskName MYvm3

$GETNEWVM = Get-AzVM -Name $NewVmname -ResourceGroupName $newvmRG

$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -VM $GETNEWVM  -ManagedDiskId $getdisk.Id -Name $getdisk.Name -Lun 0

#$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $GETNEWVM  -ManagedDiskId $getdisk.Id

Update-AzVM -VM $GETNEWVM -ResourceGroupName $newvmRG
}


$GETNEWVM
###############################################################################################################################

$dataDisks
$luncount = $dataDisks.Count

foreach($adddatadisk in $dataDisks){
for($lun1 = 1; $lun1 -le $luncount ; $lun1++)

{ 
$getdisk = Get-AzDisk -ResourceGroupName $newvmRG -DiskName $adddatadisk

$GETNEWVM = Get-AzVM -Name $NewVmname -ResourceGroupName $newvmRG

$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -VM $GETNEWVM  -ManagedDiskId $getdisk.Id -Name $getdisk.Name -Lun $lun1

#$GETNEWVM  = Add-AzVMDataDisk -CreateOption Attach -Lun 1 -VM $GETNEWVM  -ManagedDiskId $getdisk.Id

Update-AzVM -VM $GETNEWVM -ResourceGroupName $newvmRG -ErrorAction Ignore}
}


