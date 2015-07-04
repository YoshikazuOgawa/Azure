#Requires -Version 4.0

<#
.NOTES
Author: y-ogawa
Created: 5/July/2015
#>

# CONSTANT
Set-Variable -name LINUX -value 0 -option constant
Set-Variable -name WINDOWS -value 1 -option constant
Set-Variable -name SINGLE_NIC -value 0 -option constant
Set-Variable -name MULTI_NIC -value 1 -option constant
Set-Variable -name YES -value 0 -option constant
Set-Variable -name NO -value 1 -option constant
Set-Variable -name SUCCESS -value "True" -option constant
Set-Variable -name FAILURE -value "False" -option constant

# Add Azure account
$flg = $FAILURE
$input_answer = $NO
while ( $flg -ne $SUCCESS )
{
  try
  {
    $azure_account_info = Get-AzureAccount
    if ( $azure_account_info -ne "" )
    {
      Write-Output $azure_account_info
      $input_answer = Read-Host "Do you add azure account? please answer $YES(yes) or $NO(no) [default: $NO]"
      switch -case ( $input_answer )
      {
        # case 0
        $YES
        {
          try
          {
          Add-AzureAccount
            if ( $? -eq $SUCCESS )
            {
              Write-Output "Add Azure account success."
              $flg = $SUCCESS
            }
            else
            {
              Write-Output "Add Azure account failure."
              $flg = $FAILURE
            }
          }
          catch
          {
            Write-Output "Add Azure account exception failure."
            $flg = $FAILURE
          }
        }
        
        # case 1 
        $NO
        {
          $flg = $SUCCESS
        }

        # case defailt
        default
        {
          $flg = $SUCCESS
        }
      }
      # end switch
    }
    else
    {
      try
      {
        Add-AzureAccount
        if ( $? -eq $SUCCESS )
        {
          Write-Output "Add Azure account success."
          $flg = $SUCCESS
        }
        else
        {
          Write-Output "Add Azure account failure."
          $flg = $FAILURE
        }
      }
      catch
      {
        Write-Output "Add Azure account exception failure."
        $flg = $FAILURE
      }
    }
  }
  catch
  {
    Write-Output "Get Azure account exception failure."
    $flg = $FAILURE
  }
}

# Set Azure subscription and get Azure Storage Account
$set_subscription_name = "無料評価版"
$input_answer = $NO
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_answer = Read-Host 'Do you change type an azure subscription from 無償版? $YES(yes) or $NO(no) [default: $NO]'
  switch -case ( $input_answer )
  {
    # case 0
    $YES
    {
      $input_my_subscription_name = Read-Host "enter your azure subscription name"
      $set_subscription_name = $input_my_subscription_name
      Write-Output "use azure subscription: $set_subscription_name"
    }

    # case 1
    $NO
    {
      Write-Output "use azure subscription: $set_subscription_name"
    }

    # case default
    default
    {
      Write-Output "use azure subscription: $set_subscription_name"
    }
  }

  try
  {
    Set-AzureSubscription -SubscriptionName $set_subscription_name -CurrentStorageAccountName (Get-AzureStorageAccount).Label -PassThru
    if ( $? -eq $SUCCESS )
    {
      Write-Output "Set Azure subscription success."
      $flg = $SUCCESS
    }
    else
    {
      Write-Output "Set Azure subscription failure."
      $flg = $FAILURE
    }
  }
  catch
  {
      Write-Output "Set Azure subscription exception failure."
      $flg = $FAILURE
  }
}

# Set Azure Storage Account
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_storage_account = Read-Host "please enter your Azure Storage Account"
  try
  {
    Set-AzureSubscription -SubscriptionName $set_subscription_name -CurrentStorageAccount $input_storage_account
    if ( $? -eq $SUCCESS )
    {
      Write-Output "Set Azure Storage Account success."
      $flg = $SUCCESS
    }
    else
    {
      Write-Output "Set Azure Storage Account failure."
      $flg = $FAILURE
    }
  }
  catch
  {
    Write-Output "Set Azure Storage Account exception failure."
    $flg = $FAILURE
  }
}

# Get Azure VM Image
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  Write-Output "Get Azure VM Image hint: 'Get-AzureVMImage | Sort-Object OS,Label,PublishedDate | Format-Table ImageName -AutoSize'"
  $input_vmimage_name = Read-Host "please enter Azure VM image name"
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
      Write-Output "Get AzureVMImage exception failure."
      $flg = $FAILURE
  }
}

# Create Azure configuration
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_hostname = Read-Host "please enter azure vm host name"
  $input_instance_size = Read-Host "please enter azure vm instance size"
  $input_availability_name = Read-Host "please enter azure availability name"
  $vm = New-AzureVMConfig -Name $input_hostname -InstanceSize $input_instance_size -Image $image.ImageName -AvailabilitySetName $input_availability_name
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
    Write-Output "Create new azure vm configuration exception failure."
    $flg = $FAILURE
  }
}

# Add Azure provisioning configuration and create Administrator's login information
$flg = $FAILURE
$input_os_type = $LINUX
while ( $flg -ne $SUCCESS )
{
  $input_os_adminuser_name = Read-Host "please enter OS administration user's name"
  $input_os_adminuser_passwd = Read-Host "please enter OS administration user's password"
  $input_os_type = Read-Host "please enter a OS type number '0:Linux' or '1:Windows' [default:0]"
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
  $input_nic_type = Read-Host "please enter a nic type number '0:single' or '1:multi' [default:0]"
  switch -case ( $input_nic_type )
  {
    $SINGLE_NIC { $nic_type = $SINGLE_NIC }
    $MULTI_NIC { $nic_type = $MULTI_NIC }
    default { $nic_type = $SINGLE_NIC }
  }

  if ( $nic_type -eq $SINGLE_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "please enter Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "please enter Azure virtual network IP address(for firt nic ip address)"
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
      Write-Output "exception fail 1st network interface card configuration."
      $flg = $FAILURE
    }
  }
  elseif ( $nic_type -eq $MULTI_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "please enter Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "please enter Azure virtual network IP address(for firt nic ip address)"
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
      Write-Output "exception fail 1st network interface card configuration."
      $flg = $FAILURE
    }

    # Start Multi-NIC configration
    Write-Output "start multi-nic configuration."

    # Start 2nd NIC configuration
    $input_subnet_name[1] = Read-Host "please enter Azure subnet name(for 2nd nic network)"
    $input_vnet_ip[1] = Read-Host "please enter Azure virtual network IP address(for 2nd nic ip address)"
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
      Write-Output "exception fail 2nd network interface card configuration."
      $flg = $FAILURE
    }
    
    # Start 3rd NIC configuration
    $input_subnet_name[2] = Read-Host "please enter Azure subnet name(for 3rd nic network)"
    $input_vnet_ip[2] = Read-Host "please enter Azure virtual network IP address(for 3rd nic ip address)"
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
      Write-Output "exception fail 3rd network interface card configuration."
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
  $input_azure_service_name = Read-Host "please enter an Azure service name"
  $input_azure_vnet_name = Read-Host "please enter an Azure virtual network name"
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
      Write-Output "Create VM on Azure exception failure"
      $flg = $FAILURE
  }
}
