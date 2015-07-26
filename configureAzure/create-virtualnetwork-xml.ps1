#Requires -Version 3.0
Set-Variable -name VNETCONF -value "vnetconfig.xml" -option constant

$input_vnet_name = Read-Host "Please enter create Virtual Network name:"
$input_affinity_group = Read-Host "Please enter your AffinityGroup"
$input_address_prefix = Read-Host "Please enter address prefix [example:10.0.0.0/8]:"
$input_subnet_num = Read-Host "Please enter create subnet number:"

for ( $i = 0; $i < $input_subnet_num; $i++ )
{
  $input_subnet_name[$i] = Read-Host "Please enter Subnet number $i name:"
  $input_subnet_prefix[$i] = Read-Host "Please enter Subnet number $i prefix:"
}

echo '<?xml version="1.0" encoding="utf-8"?>' >> $VNETCONF
echo '<NetworkConfiguration xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.microsoft.com/ServiceHosting/2011/07/NetworkConfiguration">' >> $VNETCONF
echo '  <VirtualNetworkConfiguration>' >> $VNETCONF
echo '    <Dns />' >> $VNETCONF
echo '      <VirtualNetworkSites>' >> $VNETCONF
echo "        <VirtualNetworkSite name="$input_vnet_name" AffinityGroup="$input_affinity_group">" >> $VNETCONF
echo '          <AddressSpace>' >> $VNETCONF
echo "            <AddressPrefix>"$input_address_prefix"</AddressPrefix>" >> $VNETCONF
echo '          </AddressSpace>' >> $VNETCONF

for ( $i = 0; $i < $input_subnet_num; $i++ )
{
echo '          <Subnets>' >> $VNETCONF
echo "            <Subnet name="$input_subnet_name[$i]">" >> $VNETCONF
echo "              <AddressPrefix>"$input_subnet_prefix[$i]"</AddressPrefix>" >> $VNETCONF
echo '            </Subnet>' >> $VNETCONF
echo '          </Subnets>' >> $VNETCONF
}

echo '      </VirtualNetworkSite>' >> $VNETCONF
echo '    </VirtualNetworkSites>' >> $VNETCONF
echo '  </VirtualNetworkConfiguration>' >> $VNETCONF
echo '</NetworkConfiguration>' >> $VNETCONF
