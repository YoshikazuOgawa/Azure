# CONSTANT
Set-Variable -name SUCCESS -value 0 -option constant
Set-Variable -name LINUX -value 0 -option constant
Set-Variable -name WINDOWS -value 1 -option constant
Set-Variable -name SINGLE_NIC -value 0 -option constant
Set-Variable -name MULTI_NIC -value 1 -option constant

# Add Azure account
Add-AzureAccount

# Get Azure VM Image
$flg = 1
while ( $flg -ne $SUCCESS )
{
  $input_vmimage_name = Read-Host "Please input Azure VM image name"
  try
  {
    Get-AzureVMImage -ImageName "$input_vmimage_name"
    if ( $? -eq $SUCCESS )
    {
      $image = New-AzureVMImage -ImageName "$input_vmimage_name"
      Write-Output "Get AzureVMImage success."
      Write-Output "$image"
      $flg = 0
    }
    else
    {
      Write-Output "Get AzureVMImage failure."
      $flg = 1
    }
  }
  catch
  {
      Write-Output "Get AzureVMImage exeption failure."
      $flg = 1
  }
}

# Create Azure configuration
$flg = 1
while ( $flg -ne $SUCCESS )
{
  $input_hostname = Read-Host "Please input azure vm host name"
  $input_instance_size = Read-Host "Please input azure vm instance size"
  $input_availability_name = Read-Host "Please input azure availability name"
  New-AzureVMConfig -Name $input_hostname -InstanceSize $input_instance_size -Image $image.ImageName -AvalabilitySetName $input_avalability_name
  if ( $? -eq $SUCCESS )
  {
    $vm = New-AzureVMConfig -Name $input_hostname -InstanceSize $input_instance_size -Image $image.ImageName -AvalabilitySetName $input_avalability_name
    Write-Output "Create new azure vm configuration success."
    $flg = 0
  }
  else
  {
    Write-Output "Create new azure vm configuration failure."
    $flg = 1
  }
}

# Add Azure provisioning configuration and create Administrator's login information
$flg = 1
$input_os_type = $LINUX
while ( $flg -ne $SUCCESS )
{
  $input_os_adminuser_name = Read-Host "Please input OS administration user's name"
  $input_os_adminuser_passwd = Read-Host "Please input OS administration user's password"
  $input_os_type = Read-Host "Please input a OS type number '0:Linux' or '1:Windows' [default:0]"
  switch -case ( $input_os_type )
  {
    $LINUX { Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd }
    $WINDOWS { Add-AzureProvisioningConfig -VM $vm $input_os_type -AdminUserName $input_os_adminuser_name -Password $input_os_adminuser_passwd }
    default { Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd }
  }

  if ( $? -eq $SUCCESS )
  {
     Write-Output "Add Azure provisioning configuration SUCCESS."
     flg = 0
  }
  else
  {
     Write-Output "Add Azure provisioning configuration FAILURE."
     flg = 1
  }
}

# Add Azure VM network interface card
$flg = 1
$input_nic_type = $SINGLE_NIC
while ( $flg -ne $SUCCESS )
{
  $input_nic_type = Read-Host "Please input a nic type number '0:single' or '1:multi' [default:0]"
  switch -case ( $input_nic_type )
  {
    $SINGLE_NIC { $nic_type = $SINGLE_NIC }
    $MULTI_NIC { $nic_type = $MULTI_NIC }
    default { $nic_type = $SINGLE_NIC }
  }

  if ( $nic_type -eq $SINGLE_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please input Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please input Azure virtual network IP address(for firt nic ip address)"
    Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm
    if ( $? -eq 0 )
    {
      Write-Output "finish 1st network interface card configuration."
      $flg = 0
    }
    else
    { 
      Write-Output "fail 1st network interface card configuration."
      $flg = 1
    }
  }
  elseif ( $nic_type -eq $MULTI_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please input Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please input Azure virtual network IP address(for firt nic ip address)"
    Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm
    if ( $? -eq 0 )
    {
      Write-Output "finish 1st network interface card configuration."
      $flg = 0
    }
    else
    { 
      Write-Output "fail 1st network interface card configuration."
      $flg = 1
    }

    Write-Output "start multi-nic configuration."
    $input_subnet_name[1] = Read-Host "Please input Azure subnet name(for 2nd nic network)"
    $input_vnet_ip[1] = Read-Host "Please input Azure virtual network IP address(for 2nd nic ip address)"
    Add-AzureNetworkInterfaceConfig -Name NIC1 -SubnetName $input_subnet_name[1] -StaticVNetIPAddress $input_vnet_ip[1] -VM $vm
    if ( $? -eq 0 )
    {
      Write-Output "finish 2nd network interface card configuration."
      $flg = 0
    }
    else
    { 
      Write-Output "fail 2nd network interface card configuration."
      $flg = 1
    }
    
    $input_subnet_name[2] = Read-Host "Please input Azure subnet name(for 3rd nic network)"
    $input_vnet_ip[2] = Read-Host "Please input Azure virtual network IP address(for 3rd nic ip address)"
    Add-AzureNetworkInterfaceConfig -Name NIC1 -SubnetName $input_subnet_name[2] -StaticVNetIPAddress $input_vnet_ip[2] -VM $vm
    if ( $? -eq 0 )
    {
      Write-Output "finish 3rd network interface card configuration."
      $flg = 0
    }
    else
    { 
      Write-Output "fail 3rd network interface card configuration."
      $flg = 1
    }
  }
  else 
  {
    Write-Output "nic type error."
    $flg = 1
  }
}

# Create VM on Azure
$flg = 1
while ( $flg -ne $SUCCESS )
{
  $input_azure_service_name = Read-Host "Please input an Azure service name"
  $input_azure_vnet_name = Read-Host "Please input an Azure virtual network name"
  New-AzureVM -ServiceName $input_azure_service_name -VNetName $input_azure_vnet_name -VMs $vm
  if ( $? -eq $SUCCESS )
  {
    Write-Output "Create VM on Azure success."
    $flg = 0 
  }
  else
  {
    Write-Output "Create VM on Azure failure."
    exit
  }
}
