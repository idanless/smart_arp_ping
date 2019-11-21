# smart_arp_ping
check latency and identify hosts
<p><span style="text-decoration: underline;"><strong>setup:</strong></span></p>
<ul>
<li>sudo apt-get install iputils-arping</li>
<li>sudo apt-get install jq</li>
<li>sudo apt install moreutils</li>
<li>sudo apt install gupnp-tools</li>
<li>sudo apt-get install avahi-discover</li>
</ul>
<p><span style="text-decoration: underline;"><strong>table output:</strong></span></p>
<p>&nbsp;month,day,time,ip,mac,latency(ms),model(upnp),mds,OUI</p>
<ol>
<li><strong><em>Nov,21,23:47:37,00.00.00.00,xx:xx:xx:xx:xx:xx,5.947,N\A,raspberrypi,Raspberry Pi Foundation</em></strong></li>
<li><strong><em>Nov,21,23:46:51,00.00.00.00,xx:xx:xx:xx:xx:xx,5.553,MIBOX3,Android-3,REALTEK SEMICONDUCTOR CORP.</em></strong></li>
</ol>
<p>you can unsig by while true loop and monitor you network</p>
<p>(while true;do bash arping.sh ; sleep 20 ; done&amp;)</p>
