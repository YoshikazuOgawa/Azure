#Requires -Version 3.0

<#
.NOTES
Author: y-ogawa
Created: 9/July/2015
#>

# CONSTANT
Set-Variable -name LINUX -value 0 -option constant
Set-Variable -name WINDOWS -value 1 -option constant
Set-Variable -name SINGLE_NIC -value 0 -option constant
Set-Variable -name MULTI_NIC -value 1 -option constant
Set-Variable -name DEFAULT -value 0 -option constant
Set-Variable -name CUSTOM -value 1 -option constant
Set-Variable -name YES -value 0 -option constant
Set-Variable -name NO -value 1 -option constant
Set-Variable -name SUCCESS -value "True" -option constant
Set-Variable -name FAILURE -value "False" -option constant

Set-Variable -name CENTOS -value 0 -option constant
Set-Variable -name ORACLE_LINUX -value 1 -option constant
Set-Variable -name SUSE_LINUX_ES -value 2 -option constant
Set-Variable -name OPENSUSE -value 3 -option constant
Set-Variable -name UBUNTU -value 4 -option constant
Set-Variable -name WINDOWS_SERVER -value 5 -option constant

Set-Variable -name SMALL -value 0 -option constant
Set-Variable -name LARGE -value 1 -option constant
Set-Variable -name EXTRALARGE -value 2 -option constant

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
      $input_answer = Read-Host "Do you add Azure account? [$YES] YES or [$NO] NO [default:$NO]"
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
            exit
          }
        }
        
        # case 1 
        $NO
        {
	  Write-Output "use default account."
          $flg = $SUCCESS
        }

        # case defailt
        default
        {
	  "use default account."
          $flg = $SUCCESS
        }
      }
      # end of switch
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
        exit
      }
    }
  }
  catch
  {
    Write-Output "Get Azure account exception failure."
    exit
  }
}

# Set Azure subscription
$set_subscription_name = '無料評価版'
$input_answer = $NO
$flg = $FAILURE
$input_answer = Read-Host "Do you change type an Azure subscription from "$set_subscription_name"? [$YES] YES [$NO] NO [default:$NO]"
switch -case ( $input_answer )
{
  # case 0
  $YES
  {
    $input_my_subscription_name = Read-Host "Please enter your Azure subscription name"
    $set_subscription_name = $input_my_subscription_name
    Write-Output "use Azure subscription: $set_subscription_name"
  }

  # case 1
  $NO
  {
    Write-Output "use Azure subscription: $set_subscription_name"
  }

  # case default
  default
  {
    Write-Output "use Azure subscription: $set_subscription_name"
  }
}

# Create Azure AffinityGroup
$flg = $FAILURE
$input_answer = $NO
while ( $flg -ne $SUCCESS )
{
  Get-AzureAffinityGroup
  $input_answer = Read-Host "Do you create new Azure AffinityGroup? [$YES] YES [$NO] NO [default:$NO]"
  switch -case ( $input_answer )
  {
    # case YES
    $YES
    {
        $input_ag_name = Read-Host "Please enter an Azure AffinityGroup name"
	$input_ag_location = Read-Host "Please enter an Azure Affinity Group location [日本:"Japan West"]"
      try
      {
          New-AzureAffinityGroup -Name $input_ag_name -Location $input_ag_location
	if ( $? -eq $SUCCESS )
	{
	  Write-Output "Create new Azure AffinityGroup success."
	  $flg = $SUCCESS
	}
	else
	{
	  Write-Output "Create new Azure AffinityGroup failure."
	  $flg = $FAILURE
        }
      }
      catch
      {
        Write-Output "Create new Azure AffinityGroup exception failure."
        $flg = $FAILURE
      }
    }

    # case NO
    $NO
    {
      Write-Output "Use a existing AffnityGroup."
      $flg = $SUCCESS
    }

    # case default
    default
    {
      Write-Output "Use a existing AffnityGroup."
      $flg = $SUCCESS
    }
  } # end of switch
}

# Create Azure StorageAccount
$flg = $FAILURE
$input_answer = $NO
while ( $flg -ne $SUCCESS )
{
  Get-AzureStorageAccount
  Write-Output "Create Azure StorageAccount: hint: https://azure.microsoft.com/ja-jp/documentation/articles/storage-introduction/"
  $input_answer = Read-Host "Do you create new Azure StorageAccount? [$YES] YES [$NO] NO [default:$NO]"
  switch -case ( $input_answer )
  {
    # case YES
    $YES
    {
      $input_storage_account = Read-Host "Please create new your Azure StorageAccount"
      try
      {
        New-AzureStorageAccount -StorageAccountName "$input_storage_accont" -AffinityGroup "$input_affinity_group"
	if ( $? -eq $SUCCESS )
        {
	  Write-Output "Create new Azure StorageAccount success."
	  $flg = $SUCCESS
	}
	else
	{
	  Write-Output "Create new Azure StorageAccount failure."
	  $flg = $FAILURE
	}
      }
      catch
      {
	  Write-Output "Create new Azure StorageAccount exception failure."
	  exit
      }
    }

    # case NO
    $NO
    {
      Write-Output "Use existing Storage Account."
      $flg = $SUCCESS
    }

    default
    {
      Write-Output "Use existing Storage Account."
      $flg = $SUCCESS
    }
  }
  # end of switch
}

# Set Azure StorageAccount
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
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
      exit
  }
}

# Set Azure Storage Account
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  Write-Output "Azure StorageAccount hint: Get-AzureStorageAccount->Properties->[StorageAccount, <your_storage_account>]"
  $input_storage_account = Read-Host "Please enter your Azure StorageAccount"
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
    exit
  }
}

# Get Azure VM Image
$flg = $FAILURE
$input_os_type_num = $CENTOS
while ( $flg -ne $SUCCESS )
{
  Get-AzureVMImage | Sort-Object OS,Label,PublishedDate | Format-Table ImageName -AutoSize > Get-AzureVMImage.tmp
  $input_os_type_num = Read-Host "Please input os type number [0] CentOS [1] Oralce Linux [2] SLES [3] OPENSUSE [4] Ubuntu [5] Windows Server [default:0]"
  switch ( $input_os_type_num )
  {
    # case CentOS
    $CENTOS
    {
      cat Get-AzureVMImage.tmp | Select-String CentOS
    }

    # case Oracle Linux
    $ORACLE_LINUX
    {
      cat Get-AzureVMImage.tmp | Select-String Oracle-Linux
    }

    # case SUSE Linux Enterprise Server
    $SUSE_LINUX_ES
    {
      cat Get-AzureVMImage.tmp | Select-String sles
    }

    # case SUSE
    $OPENSUSE
    {
      cat Get-AzureVMImage.tmp | Select-String openSUSE
      cat Get-AzureVMImage.tmp | Select-String opensuse
    }

    # case Ubuntu
    $UBUNTU
    {
      cat Get-AzureVMImage.tmp | Select-String Ubuntu
    }

    # case Windows Server
    $WINDOWS_SERVER
    {
      cat Get-AzureVMImage.tmp | Select-String Windows-Server
    }

    # case default
    default
    {
      cat Get-AzureVMImage.tmp | Select-String CentOS
    }
  }
 
  Write-Output "VM Image name hint:  Line  : <vm image name>"
  $input_vmimage_name = Read-Host "Please enter Azure VM image name"
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
      exit
  }
}

# Create Azure configuration
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_hostname = Read-Host "Please enter azure vm host name"
  $input_instance_size = Read-Host "Please enter azure vm instance size"
  $input_availability_name = Read-Host "Please enter azure availability name"
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
    exit
  }
}

# Add Azure provisioning configuration and create Administrator's login information
$flg = $FAILURE
$input_os_type = $LINUX
while ( $flg -ne $SUCCESS )
{
  $input_os_adminuser_name = Read-Host "Please enter OS administration user's name"
  $input_os_adminuser_passwd = Read-Host "Please enter OS administration user's password"
  $input_os_type = Read-Host "Please enter a OS type number [$LINUX] Linux [$WINDOWS] Windows [default:$LINUX]"
  switch -case ( $input_os_type )
  {
    # case Linux
    $LINUX
    {
      try
      {
        Add-AzureProvisioningConfig -VM $vm -Linux -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd
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
        Add-AzureProvisioningConfig -VM $vm -Windows -AdminUserName $input_os_adminuser_name -Password $input_os_adminuser_passwd
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
        Add-AzureProvisioningConfig -VM $vm -Linux -LinuxUser $input_os_adminuser_name -Password $input_os_adminuser_passwd
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
$input_vnet_ip = @("", "", "")
$input_subnet_name = @("", "", "")
while ( $flg -ne $SUCCESS )
{
  $input_nic_type = Read-Host "Please enter a nic type number '0:single' or '1:multi' [default:0]"
  switch -case ( $input_nic_type )
  {
    $SINGLE_NIC { $nic_type = $SINGLE_NIC }
    $MULTI_NIC { $nic_type = $MULTI_NIC }
    default { $nic_type = $SINGLE_NIC }
  }

  if ( $nic_type -eq $SINGLE_NIC )
  {
    Write-Output "start first network interface card configuration."
    $input_subnet_name[0] = Read-Host "Please enter Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please enter Azure virtual network IP address(for firt nic ip address)"
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
    $input_subnet_name[0] = Read-Host "Please enter Azure subnet name(for first nic network)"
    $input_vnet_ip[0] = Read-Host "Please enter Azure virtual network IP address(for firt nic ip address)"
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
    $input_subnet_name[1] = Read-Host "Please enter Azure subnet name(for 2nd nic network)"
    $input_vnet_ip[1] = Read-Host "Please enter Azure virtual network IP address(for 2nd nic ip address)"
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

    $input_answer = Read-Host "Do you add 3rd nic? [$YES] YES [$NO] NO [default:$NO]"
      switch -case ( $input_answer )
      {
        # case YES
        $YES
        {
        # Start 3rd NIC configuration
        $input_subnet_name[2] = Read-Host "Please enter Azure subnet name(for 3rd nic network)"
        $input_vnet_ip[2] = Read-Host "Please enter Azure virtual network IP address(for 3rd nic ip address)"
          try
          {
            Add-AzureNetworkInterfaceConfig -Name NIC2 -SubnetName $input_subnet_name[2] -StaticVNetIPAddress $input_vnet_ip[2] -VM $vm
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
  }
}

# Create VM on Azure
$flg = $FAILURE
while ( $flg -ne $SUCCESS )
{
  $input_azure_service_name = Read-Host "Please enter an Azure service name"
  $input_azure_vnet_name = Read-Host "Please enter an Azure virtual network name"
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
