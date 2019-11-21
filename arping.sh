#!/bin/sh

send_arp_ping()
{
url=$(gssdp-discover -i eno1 --timeout=1 | grep "Location:" | cut -d ' ' -f4 | grep  "$1"  |sort -u)
check_upnp
data_ping=$(arping -w 1 -c 1  -I eno1  $1 | grep Uni | cut -c 19-60 | sed 's/[\t ]+/,/g'  | cut -d ' ' -f2-10 |  tr -d {}[] | ts | awk '{$1=$1}1' OFS="," | sed 's/ms//'|sed 's/m//')
check_OUI
if [ -z $data_ping ]
then
     echo "empty" >> /dev/null

else
	echo $data_ping,$model,$oui

     
fi

}


check_arp_ping()
{
while true ;
do
count=$(ps -aux | grep "arping -w 1" | grep -v "color=auto" | wc -l)
if [ $count -lt 50 ]
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

for i  in {1..254} 
 do 
#echo test 192.168.0.$i
check_arp_ping
send_arp_ping 192.168.1.$i &
done
