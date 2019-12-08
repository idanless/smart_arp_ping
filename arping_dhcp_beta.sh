#!/bin/sh

interface=enp1s0
#/24
ip_addr=10.100.102
thread=30
output_file=arp_data.csv

send_arp_ping()

{

IP=$(echo $1)
data_ping=$(arping -w 1 -c 1  -I $interface  $IP | grep Uni | cut -c 19-60 | sed 's/[\t ]+/,/g'  | cut -d ' ' -f2-10 |  tr -d {}[] | ts | awk '{$1=$1}1' OFS="," | sed 's/ms//' | sed 's/m//' )
if [ -z $data_ping ]
then
     echo "empty" >> /dev/null

else
	#echo $data_ping,$model,$oui
	url=$(gssdp-discover -i $interface --timeout=3 | grep "Location:" | cut -d ' ' -f4 | grep -w  "$1" |grep -E 'Desc|desc' |sort -u|head -n1)
	check_OUI
	check_bonjour
	check_upnp
 device=$( echo $data_ping | cut -d ',' -f5 | tr '[:upper:]' '[:lower:]')
 dhcp_check
   #echo $data_ping,$model,$mdns,$Vendor_class,$Host_name,$oui
	echo $data_ping,$model,$mdns,$Vendor_class,$Host_name,$oui>>$output_file
 
     
fi

}


check_arp_ping()
{
while true ;
do
count=$(ps -aux | grep "arping -w 1" | grep -v "color=auto" | wc -l)
if [ $count -lt $thread ]
then
break 
fi
done
}


dhcp_check()
{

Vendor_class=$( cat dhcp.log  | grep -A 4  -B 1 "$device" | grep "Vendor class identifier" | sort -u | awk '{$1=$1}1' OFS=","  | cut -d ',' -f8)
Host_name=$(cat dhcp.log  | grep -A 4  -B 1 "$device" | grep "Host name" | sort -u | awk '{$1=$1}1' OFS=","  | cut -d ',' -f7)
if [ -z $Vendor_class ]
then
      Vendor_class=$(echo "N\A")
    
fi

if [ -z $Host_name ]
then
      Host_name=$(echo "N\A")
    
fi

}



dhcp_disconnected()
{
HH=$( date +"%H:%M" | cut -d ':'  -f1)
MM=$( date +"%H:%M" | cut -d ':'  -f2)
 if [ $HH = 23 ] && [ $MM -gt 58 ]
 then
 list_hosts=$(cat arp_data.csv | cut -d ',' -f5 | sort -u| tr '[:upper:]' '[:lower:]')
for  mac in $(echo $list_hosts)
do
list_time=$(cat dhcp.log  | grep -A 1  -B 20 "01:$mac" | grep -A 8 "DHCPDISCOVER" | grep "TIME" | grep $( date +%Y-%m-%d) | cut -d ' ' -f5 | cut -d '.' -f1  | sort -u)
    for DHCPDISCOVER in $(echo $list_time)
    do 
       echo $( date +%d-%m-%Y),$mac,$DHCPDISCOVER>>sum_disconnected.csv
    done
    
done

fi


}

check_file_dhcp_disconnected()
{
number=$(stat -c '%y' sum_disconnected.csv | grep $( date +%Y-%m-%d) | wc -l)
if [ $number = 1 ]
 then
 echo "no update need" 
 else
 dhcp_disconnected
 fi
}


check_OUI()
{

if [ -z $data_ping ]
then
      oui=$(echo "N\A")

else
	mac_check=$(echo $data_ping | cut -d ','  -f5)
	oui=$(curl -s https://macvendors.co/api/$mac_check | jq -r '.result .company')

     
fi

}






check_upnp()
{
if [ -z $url ]
then
      model=$(echo "N\A")

else
	model=$(curl -s $url| tr '<' '\n' | grep "modelName>" | head -n1  | sed 's/modelName>//')
     
fi

}


check_bonjour()
{

bonjour_host=$(avahi-resolve  --address $IP |  awk '{$1=$1}1' OFS=","|cut -d ',' -f2 | cut -d '.' -f1)
if [ -z $bonjour_host ]
then
      mdns=$(echo "N\A")

else
        mdns=$(echo $bonjour_host)

fi


}

check_file_dhcp_disconnected
for i  in {1..254} 
 do 
#echo test 192.168.0.$i
check_arp_ping
send_arp_ping $ip_addr.$i &
done

