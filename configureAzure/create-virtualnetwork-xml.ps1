#Requires -Version 3.0
Set-Variable -name VNETCONF -value "netcfg.xml" -option constant

$input_subnet_name = @("")
$input_subnet_prefix = @("")

$input_vnet_name = Read-Host "Please enter create Virtual Network name"
$input_affinity_group = Read-Host "Please enter your AffinityGroup"
$input_address_prefix = Read-Host "Please enter address prefix [example:10.0.0.0/8]"
$input_subnet_num = Read-Host "Please enter create subnet number"

$input_subnet_name += $input_subnet_num
$input_subnet_prefix += $input_subnet_num

#for ( $i = 0; $i -lt $input_subnet_num; $i++ )
#{
#  $subnet_num = $i + 1
#  $input_subnet_name[$i] = Read-Host "Please enter Subnet name (number $subnet_num)"
#  $input_subnet_prefix[$i] = Read-Host "Please enter Subnet prefix (number $subnet_num)"
#}

echo '<?xml version="1.0" encoding="utf-8"?>' >> $VNETCONF
echo '<NetworkConfiguration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/ServiceHosting/2011/07/NetworkConfiguration">' >> $VNETCONF
echo '  <VirtualNetworkConfiguration>' >> $VNETCONF
echo '    <Dns />' >> $VNETCONF
echo '      <VirtualNetworkSites>' >> $VNETCONF
echo "        <VirtualNetworkSite name=$input_vnet_name AffinityGroup=$input_affinity_group>" >> $VNETCONF
echo '          <AddressSpace>' >> $VNETCONF
echo "            <AddressPrefix>$input_address_prefix</AddressPrefix>" >> $VNETCONF
echo '          </AddressSpace>' >> $VNETCONF

for ( $i = 0; $i -lt $input_subnet_num; $i++ )
{
echo '          <Subnets>' >> $VNETCONF
$subnet_num = $i + 1
$input_subnet_name[$i] = Read-Host "Please enter Subnet name (number $subnet_num)"
$input_subnet_prefix[$i] = Read-Host "Please enter Subnet prefix (number $subnet_num)"
$ret_subnet_name = $input_subnet_name[$i]
$ret_subnet_prefix = $input_subnet_name[$i]

echo $("            <Subnet name=" + "$ret_subnet_name" + ">") >> $VNETCONF
echo $("              <AddressPrefix>" + "$ret_subnet_prefix" + "</AddressPrefix>") >> $VNETCONF
echo '            </Subnet>' >> $VNETCONF
echo '          </Subnets>' >> $VNETCONF
}

echo '      </VirtualNetworkSite>' >> $VNETCONF
echo '    </VirtualNetworkSites>' >> $VNETCONF
echo '  </VirtualNetworkConfiguration>' >> $VNETCONF
echo '</NetworkConfiguration>' >> $VNETCONF
