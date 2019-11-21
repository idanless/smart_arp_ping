# smart_arp_ping
check latency and identify hosts
<p><span style="text-decoration: underline;"><strong>setup:</strong></span></p>
<p>sudo apt-get install iputils-arping</p>
<p>sudo apt-get install jq</p>
<p>sudo apt install moreutils</p>
<p>sudo apt install gupnp-tools</p>
<p>sudo apt-get install avahi-discover</p>
<p>table output:</p>
<p>&nbsp;month,day,time,ip,mac,latency(ms),model(upnp),mds,OUI</p>
<p>Nov,21,23:47:37,00.00.00.00,xx:xx:xx:xx:xx:xx,5.947,N\A,raspberrypi,Raspberry Pi Foundation</p>
<p>Nov,21,23:46:51,00.00.00.00,xx:xx:xx:xx:xx:xx,5.553,MIBOX3,Android-3,REALTEK SEMICONDUCTOR CORP.</p>
<p>you can unsig by while true loop and monitor you network</p>
<p>(while true;do bash arping.sh ; sleep 20 ; done&amp;)</p>
