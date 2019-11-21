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
	echo $data_ping,$model,$mdns,$oui>>$output_file
     
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


for i  in {1..254} 
 do 
#echo test 192.168.0.$i
check_arp_ping
send_arp_ping $ip_addr.$i &
done
