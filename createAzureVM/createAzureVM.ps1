$success=0
$failure=1

# Add Azure account
Add-AzureAccount

# Get Azure VM Image
$flg = 1
while ( $flg -ne $success )
{
  $input_vmimage_name = Read-Host "Please input Azure VM image name"
  New-AzureVMImage -ImageName "$input_vmimage_name"
  if ( $? -eq $success )
  {
    $image = New-AzureVMImage -ImageName "$input_vmimage_name"
    Write-Output "Get AzureVMImage success."
    $flg = 0
  }
  else
  {
    Write-Output "Get AzureVMImage failure."
    $flg = 1
  }
}

# Create Azure configuration
$flg = 1
while ( $flg -ne $success )
{
  $input_hostname = Read-Host "Please input azure vm host name"
  $input_instance_size = Read-Host "Please input azure vm instance size"
  $input_availability_name = Read-Host "Please input azure availability name"
  New-AzureVMConfig -Name $input_hostname -InstanceSize $input_instance_size -Image $image.ImageName -AvalabilitySetName $input_avalability_name
  if ( $? -eq $success )
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
$input_os_type = "default"
while ( $flg -ne $success )
{
  $input_os_adminuser_name = Read-Host "Please input OS administration user's name"
  $input_os_adminuser_passwd = Read-Host "Please input OS administration user's password"
  $input_os_type = Read-Host "Please input OS type Linux or Windows[default: Linux]"
  switch -case ( $input_os_type )
  {
    Linux { Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd }
    Windows { Add-AzureProvisioningConfig -VM $vm $input_os_type -AdminUserName $input_os_adminuser_name -Password $input_os_adminuser_passwd }
    default { Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd }
  }

  if ( $? -eq $success )
  {
     Write-Output "Add Azure provisioning configuration success."
     flg = 0
  }
  else
  {
     Write-Output "Add Azure provisioning configuration failure."
     flg = 1
  }
}

# Add Azure VM network interface card
$flg = 1
$nic_type = 0
while ( $flg -ne $success )
{
  $input_nic_type = Read-Host "Please input nic type single or multi[default: single]"
  switch -case ( $input_nic_type )
  {
    single { $nic_type = 0 }
    multi { $nic_type = 1 }
    default { $nic_type = 0 }
  }

  if ( $nic_type -eq 0 )
  {
    Write-output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please input Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please input Azure virtual network IP address(for firt nic ip address)"
    Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm
    if ( $? -eq 0 )
    {
      Write-output "finish first network interface card configuration."
      $flg = 0
    }
    else
    { 
      Write-output "fail first network interface card configuration."
      $flg = 1
    }
  }
  else if ( $nic_type -eq 1 )
  {
    Write-output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please input Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please input Azure virtual network IP address(for firt nic ip address)"
    Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm

    Write-Output "start multi-nic configuration."
    $input_subnet_name[1] = Read-Host "Please input Azure subnet name(for second nic network)"
    $input_vnet_ip[1] = Read-Host "Please input Azure virtual network IP address(for second nic ip address)"
  }
  else 
  {
    Write-Output "nic type error."
    $flg = 1
  }
}
