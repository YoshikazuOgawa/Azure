#Requires -Version 4.0

<#
.NOTES
Author: y-ogawa
Created: 5/July/2015
#>

# CONSTANT
Set-Variable -name SUCCESS -value "True" -option constant
Set-Variable -name FAILURE -value "False" -option constant
Set-Variable -name LINUX -value 0 -option constant
Set-Variable -name WINDOWS -value 1 -option constant
Set-Variable -name SINGLE_NIC -value 0 -option constant
Set-Variable -name MULTI_NIC -value 1 -option constant

# Add Azure account
Add-AzureAccount

# Get Azure VM Image
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_vmimage_name = Read-Host "Please input Azure VM image name"
  try
  {
    $image = Get-AzureVMImage -ImageName "$input_vmimage_name"
    if ( $? -eq $SUCCESS )
    {
      Write-Output "Get AzureVMImage success."
      $flg = $SUCCESS
    }
    else
    {
      Write-Output "Get AzureVMImage failure."
      $flg = $FAILURE
    }
  }
  catch
  {
      Write-Output "Get AzureVMImage exeption failure."
      $flg = $FAILURE
  }
}

# Create Azure configuration
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_hostname = Read-Host "Please input azure vm host name"
  $input_instance_size = Read-Host "Please input azure vm instance size"
  $input_availability_name = Read-Host "Please input azure availability name"
  $vm = New-AzureVMConfig -Name $input_hostname -InstanceSize $input_instance_size -Image $image.ImageName -AvalabilitySetName $input_avalability_name
  try
  {
    if ( $? -eq $SUCCESS )
    {
      Write-Output "Create new azure vm configuration success."
      $flg = $SUCCESS
    }
    else
    {
      Write-Output "Create new azure vm configuration failure."
      $flg = $FAILURE
    }
  }
  catch
  {
    Write-Output "Create new azure vm configuration exeption failure."
    $flg = $FAILURE
  }
}

# Add Azure provisioning configuration and create Administrator's login information
$flg = $FAILURE
$input_os_type = $LINUX
while ( $flg -ne $SUCCESS )
{
  $input_os_adminuser_name = Read-Host "Please input OS administration user's name"
  $input_os_adminuser_passwd = Read-Host "Please input OS administration user's password"
  $input_os_type = Read-Host "Please input a OS type number '0:Linux' or '1:Windows' [default:0]"
  switch -case ( $input_os_type )
  {
    # case Linux
    $LINUX
    {
      try
      {
        Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd
        if ( $? -eq $SUCCESS )
        {
          Write-Output "Add Azure provisioning configuration success."
          $flg = $SUCCESS
        }
        else
        {
          Write-Output "Add Azure provisioning configuration failure."
          $flg = $FAILURE
        }
      }
      catch
      {
        Write-Output "Add Azure provisioning configuration execption failure."
        $flg = $FAILURE
      }
    }

    # case Windows
    $WINDOWS
    {
      try
      {
        Add-AzureProvisioningConfig -VM $vm $input_os_type -AdminUserName $input_os_adminuser_name -Password $input_os_adminuser_passwd
        if ( $? -eq $SUCCESS )
        {
          Write-Output "Add Azure provisioning configuration success."
          $flg = $SUCCESS
        }
        else
        {
          Write-Output "Add Azure provisioning configuration failure."
          $flg = $FAILURE
        }
      }
      catch
      {
        Write-Output "Add Azure provisioning configuration execption failure."
        $flg = $FAILURE
      }
    }

    # case default
    default
    {
      try
      {
        Add-AzureProvisioningConfig -VM $vm $input_os_type -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd
        if ( $? -eq $SUCCESS )
        {
          Write-Output "Add Azure provisioning configuration success."
          $flg = $SUCCESS
        }
        else
        {
          Write-Output "Add Azure provisioning configuration failure."
          $flg = $FAILURE
      }
      catch
      {
        Write-Output "Add Azure provisioning configuration execption failure."
        $flg = $FAILURE
      }
    }
  }
  # end switch
}

# Add Azure VM network interface card
$flg = $FAILURE
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
    try
    {
      Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm
      if ( $? -eq $SUCCESS )
      {
        Write-Output "finish 1st network interface card configuration."
        $flg = $SUCCESS
      }
      else
      { 
        Write-Output "fail 1st network interface card configuration."
        $flg = $FAILURE
      }
    }
    catch
    {
      Write-Output "exeption fail 1st network interface card configuration."
      $flg = $FAILURE
    }
  }
  elseif ( $nic_type -eq $MULTI_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please input Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please input Azure virtual network IP address(for firt nic ip address)"
    try
    {
      Set-AzureSubnet -SubnetNames $input_subnet_name[0] -VM $vm
      if ( $? -eq $SUCCESS )
      {
        Write-Output "finish 1st network interface card configuration."
        $flg = $SUCCESS
      }
      else
      { 
        Write-Output "fail 1st network interface card configuration."
        $flg = $FAILURE
      }
    }
    catch
    {
      Write-Output "exeption fail 1st network interface card configuration."
      $flg = $FAILURE
    }

    # Start Multi-NIC configration
    Write-Output "start multi-nic configuration."

    # Start 2nd NIC configuration
    $input_subnet_name[1] = Read-Host "Please input Azure subnet name(for 2nd nic network)"
    $input_vnet_ip[1] = Read-Host "Please input Azure virtual network IP address(for 2nd nic ip address)"
    try
    {
      Add-AzureNetworkInterfaceConfig -Name NIC1 -SubnetName $input_subnet_name[1] -StaticVNetIPAddress $input_vnet_ip[1] -VM $vm
      if ( $? -eq $SUCCESS )
      {
        Write-Output "finish 2nd network interface card configuration."
        $flg = $SUCCESS
      }
      else
      { 
        Write-Output "fail 2nd network interface card configuration."
        $flg = $FAILURE
      }
    }
    catch
    {
      Write-Output "exeption fail 2nd network interface card configuration."
      $flg = $FAILURE
    }
    
    # Start 3rd NIC configuration
    $input_subnet_name[2] = Read-Host "Please input Azure subnet name(for 3rd nic network)"
    $input_vnet_ip[2] = Read-Host "Please input Azure virtual network IP address(for 3rd nic ip address)"
    try
    {
      Add-AzureNetworkInterfaceConfig -Name NIC1 -SubnetName $input_subnet_name[2] -StaticVNetIPAddress $input_vnet_ip[2] -VM $vm
      if ( $? -eq $SUCCESS )
      {
        Write-Output "finish 3rd network interface card configuration."
        $flg = $SUCCESS
      }
      else
      { 
        Write-Output "fail 3rd network interface card configuration."
        $flg = $FAILURE
      }
    }
    catch
    {
      Write-Output "exeption fail 3rd network interface card configuration."
      $flg = $FAILURE
    }
  }
  # end elseif
  else
  {
    Write-Output "NIC configuration error."
    $flg = $FAILURE
  }
}

# Create VM on Azure
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_azure_service_name = Read-Host "Please input an Azure service name"
  $input_azure_vnet_name = Read-Host "Please input an Azure virtual network name"
  try
  {
    New-AzureVM -ServiceName $input_azure_service_name -VNetName $input_azure_vnet_name -VMs $vm
    if ( $? -eq $SUCCESS )
    {
      Write-Output "Create VM on Azure success."
      $flg = $SUCCESS 
    }
    else
    {
      Write-Output "Create VM on Azure failure."
      $flg = $FAILURE
    }
  }
  catch
  {
      Write-Output "Create VM on Azure exeption failure."
      $flg = $FAILURE
  }
}
