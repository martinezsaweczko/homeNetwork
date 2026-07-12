# 2026-07-12 20:19:27 by RouterOS 7.18.2
# software id = 6PYI-181B
#
# model = RB2011UiAS-2HnD
# serial number = __REDACTED__
/interface bridge
add name=BRIDGE-LAN
/interface wireless
set [ find default-name=wlan1 ] antenna-gain=0 country=no_country_set \
    frequency-mode=manual-txpower ssid=skarpetki-2 station-roaming=enabled
/interface ethernet
set [ find default-name=ether1 ] comment="Connected to Router A ether4" name=\
    UPLINK-A
set [ find default-name=ether6 ] advertise="10M-baseT-half,10M-baseT-full,100M\
    -baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
set [ find default-name=ether7 ] advertise="10M-baseT-half,10M-baseT-full,100M\
    -baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
set [ find default-name=ether8 ] advertise="10M-baseT-half,10M-baseT-full,100M\
    -baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
set [ find default-name=ether9 ] advertise="10M-baseT-half,10M-baseT-full,100M\
    -baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
set [ find default-name=ether10 ] advertise="10M-baseT-half,10M-baseT-full,100\
    M-baseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
set [ find default-name=sfp1 ] advertise="10M-baseT-half,10M-baseT-full,100M-b\
    aseT-half,100M-baseT-full,1G-baseT-half,1G-baseT-full"
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk mode=dynamic-keys \
    supplicant-identity=MikroTik wpa2-pre-shared-key=saweczko
/ip pool
add name=DHCP_Pool_B ranges=172.26.32.100-172.26.32.254
/ip dhcp-server
add address-pool=DHCP_Pool_B interface=BRIDGE-LAN name=DHCP-B
/ip smb users
set [ find default=yes ] disabled=yes
/port
set 0 name=serial0
/routing bgp template
set default disabled=yes output.network=bgp-networks
/interface bridge port
add bridge=BRIDGE-LAN interface=ether2
add bridge=BRIDGE-LAN interface=ether3
add bridge=BRIDGE-LAN interface=ether4
add bridge=BRIDGE-LAN interface=ether5
add bridge=BRIDGE-LAN interface=ether6
add bridge=BRIDGE-LAN interface=ether7
add bridge=BRIDGE-LAN interface=ether8
add bridge=BRIDGE-LAN interface=ether9
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface detect-internet
set wan-interface-list=all
/interface ovpn-server server
add auth=sha1,md5 mac-address=__REDACTED__ name=ovpn-server1
/interface wireguard peers
add allowed-address=192.168.0.0/16 client-address=192.168.2.4/32 client-dns=\
    8.8.8.8 endpoint-address=goshi.page endpoint-port=13231 interface=*10 \
    name=VPNRubenConnect persistent-keepalive=10s public-key=__REDACTED__
add allowed-address=172.26.0.0/16 client-address=172.26.11.2/16 client-dns=\
    8.8.8.8 interface=*F name=VPMMicroTikRuben public-key=__REDACTED__
/ip address
add address=172.26.11.1/24 interface=*F network=172.26.11.0
add address=192.168.2.3/16 interface=*10 network=192.168.0.0
add address=172.26.40.2/30 interface=UPLINK-A network=172.26.40.0
add address=172.26.32.1/24 interface=BRIDGE-LAN network=172.26.32.0
/ip dhcp-server lease
add address=172.26.32.250 mac-address=__REDACTED__ server=DHCP-B \
    use-src-mac=yes
add address=172.26.32.240 mac-address=__REDACTED__ server=DHCP-B
/ip dhcp-server network
add address=172.26.32.0/24 boot-file-name=netboot.xyz.efi dns-server=\
    172.26.0.1 gateway=172.26.32.1 next-server=172.26.32.250
/ip dns
set allow-remote-requests=yes max-concurrent-queries=1000 \
    max-concurrent-tcp-sessions=200 servers=8.8.8.8,8.8.4.4
/ip firewall filter
add action=accept chain=forward comment="Accept established/related" \
    connection-state=established,related
add action=fasttrack-connection chain=forward comment=\
    "FastTrack new connections" connection-state=new hw-offload=yes
add action=log chain=input dst-port=53 log=yes log-prefix="DNS_INPUT_DROP " \
    protocol=udp
add action=accept chain=forward comment="ACCEPT Port 4000 to Final Server" \
    dst-address=172.26.32.250 dst-port=4000 protocol=tcp
add action=accept chain=forward comment="ACCEPT Port 443 to Final Server" \
    dst-address=172.26.32.250 dst-port=443 protocol=tcp
add action=accept chain=forward dst-address=172.26.32.250 dst-port=80 \
    protocol=tcp
add action=accept chain=input dst-address=172.26.32.240 dst-port=7000 \
    protocol=tcp
add action=drop chain=forward comment="Drop invalid connections" \
    connection-state=invalid
/ip firewall nat
add action=masquerade chain=srcnat comment=\
    "Masquerade for Router B LAN Internet" out-interface=UPLINK-A
add action=dst-nat chain=dstnat comment=\
    "Forward HTTPS to Server 172.26.32.250" dst-port=443 in-interface=\
    UPLINK-A protocol=tcp to-addresses=172.26.32.250 to-ports=443
add action=dst-nat chain=dstnat dst-port=80 in-interface=UPLINK-A protocol=\
    tcp to-addresses=172.26.32.250 to-ports=80
add action=dst-nat chain=dstnat comment=\
    "Router B: Forward 4000 to Server 172.26.32.250" dst-port=4000 \
    in-interface=UPLINK-A protocol=tcp to-addresses=172.26.32.250 to-ports=\
    4000
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add dst-address=0.0.0.0/0 gateway=172.26.40.1
/ip service
set www address=172.26.0.0/16 port=83
set ssh address=172.26.0.0/16
set winbox address=172.26.0.0/16
/ip smb shares
set [ find default=yes ] directory=/pub
/routing bfd configuration
add disabled=no interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/system clock
set time-zone-name=Europe/Madrid
/system identity
set name=MikroRouter
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes
/system ntp client servers
add address=es.pool.ntp.org
/system scheduler
add interval=10m name="Dyno Updater" on-event=\
    "/system script run Dyno-Updater" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
/system script
add dont-require-permissions=no name=Dyno-Updater owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local ddnsuser  "__REDACTED__"\r\
    \n:local ddnspass  "__REDACTED__"\r\
    \n:local ddnshost  "__REDACTED__"\r\
    \n\r\
    \n:local currentIP ([/tool fetch url=\"http://api.ipify.org\" as-value out\
    put=user]->\"data\")\r\
    \n:local dnsIP     [:resolve \$ddnshost]\r\
    \n:if (\$currentIP != \$dnsIP) do={\r\
    \n    :local update \"https://api.dynu.com/nic/update\?username=\$ddnsuser\
    &password=__REDACTED__
    \n    /tool fetch url=\$update keep-result=no\r\
    \n    :log info \"DYNU \$ddnshost updated to:\$currentIP old IP was \$dnsI\
    P\"\r\
    \n}"
/tool bandwidth-server
set authenticate=no
/tool graphing interface
add
