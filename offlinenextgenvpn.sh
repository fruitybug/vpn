echo "SET DATETIME and DNS start"
uci set system.@system[0].zonename='Europe/Moscow'
uci set system.@system[0].timezone='MSK-3'
uci set network.wan.peerdns="0"
uci set network.wan6.peerdns="0"
uci set network.wan.dns='1.1.1.1'
uci set network.wan6.dns='2606:4700:4700::1111'
uci set system.@system[0].hostname=NextGenVPN
uci commit system
uci commit network
uci commit
/sbin/reload_config
sleep 3

echo "SET DATETIME and DNS end"

echo "SET BANNER start"
###BANNER
>/etc/banner

echo "
███╗   ██╗███████╗██╗  ██╗████████╗ ██████╗ ███████╗███╗   ██╗██╗   ██╗██████╗ ███╗   ██╗
████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝ ██╔════╝████╗  ██║██║   ██║██╔══██╗████╗  ██║
██╔██╗ ██║█████╗   ╚███╔╝    ██║   ██║  ███╗█████╗  ██╔██╗ ██║██║   ██║██████╔╝██╔██╗ ██║
██║╚██╗██║██╔══╝   ██╔██╗    ██║   ██║   ██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██╔═══╝ ██║╚██╗██║
██║ ╚████║███████╗██╔╝ ██╗   ██║   ╚██████╔╝███████╗██║ ╚████║ ╚████╔╝ ██║     ██║ ╚████║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝     ╚═╝  ╚═══╝
                                                                                                                                               
telegram : @NextGenVPN_RU" >> /etc/banner

sleep 1
echo "SET BANNER end"


echo "SET INSTALL PACKAGE STAGE-1 start"
mkdir /tmp/ngvpack/
cd /tmp
wget https://raw.githubusercontent.com/fruitybug/vpn/main/packages.tar.gz
tar -xvzf /tmp/packages.tar.gz -C /tmp/ngvpack/
sleep 3
opkg install /tmp/ngvpack/*.ipk
echo "SET INSTALL PACKAGE STAGE-1 end"
sleep 2
echo "SET INSTALL PACKAGE STAGE-2 start"
opkg install /tmp/ngvpack/*.ipk
echo "SET INSTALL PACKAGE STAGE-2 end"
sleep 3

####CONFIG
echo "SET passwall2 config start"
uci set passwall2.@global_forwarding[0]=global_forwarding
uci set passwall2.@global_forwarding[0].tcp_no_redir_ports='disable'
uci set passwall2.@global_forwarding[0].udp_no_redir_ports='disable'
uci set passwall2.@global_forwarding[0].tcp_redir_ports='1:65535'
uci set passwall2.@global_forwarding[0].udp_redir_ports='1:65535'
uci set passwall2.@global[0].remote_dns='8.8.4.4'

echo "SET passwall2 config end"
echo "SET passwall2 rules start"
uci set passwall2.Direct=shunt_rules
uci set passwall2.Direct.network='tcp,udp'
uci set passwall2.Direct.remarks='RUSSIA'
uci set passwall2.Direct.ip_list='10.0.0.0/8
100.64.0.0/10
127.0.0.0/8
172.16.0.0/12
192.168.0.0/16
fc00::/7
geoip:ru'
uci set passwall2.Direct.domain_list='regexp:^.+\.ru$
geosite:category-ru'

uci set passwall2.myshunt.Direct='_direct'

uci commit passwall2

uci commit system
echo "SET passwall2 rules end"
sleep 3

####
echo "SET IP address start"
uci set network.lan.proto='static'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.ipaddr='192.168.24.1'
uci set network.lan.delegate='0'
uci commit network
echo "SET IP address end"

echo "SET WIFI 2G start"
uci delete wireless.radio0.disabled='1'
uci set wireless.default_radio0.ssid='Tg: NextGenVPN_bot 2G'
uci set wireless.default_radio0.encryption='psk2+ccmp'
uci set wireless.default_radio0.key='nextgenvpn001'
uci set wireless.default_radio0.mode='ap'
uci set wireless.default_radio0.network='lan'
echo "SET WIFI 2G end"

echo "SET WIFI 5G start"
uci delete wireless.radio1.disabled='1'
uci set wireless.default_radio1.ssid='Tg: NextGenVPN_bot 5G'
uci set wireless.default_radio1.encryption='psk2+ccmp'
uci set wireless.default_radio1.key='nextgenvpn001'
uci set wireless.default_radio1.mode='ap'
uci set wireless.default_radio1.network='lan'

uci commit wireless
uci commit
echo "SET WIFI 5G end"

echo "INSTALL WEB ICON OTHER start"
cd /tmp
wget https://raw.githubusercontent.com/fruitybug/vpn/main/ngvpn.zip
unzip -o ngvpn.zip -d /
echo "INSTALL WEB ICON OTHER end"
sleep 2

RED='\033[0;31m'
echo -e "${RED}** ВНИМАНИЕ СЕЙЧАС РОУТЕР ПЕРЕЗАГРУЗИТСЯ Новый IP 192.168.24.1 **"
sleep 1

reboot
