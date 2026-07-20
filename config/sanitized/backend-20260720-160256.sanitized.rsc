# jul/20/2026 16:02:56 by RouterOS 7.8
# software id = JCZK-M2GK
#
# model = RB4011iGS+
# serial number = __REDACTED__
/interface bridge
add ingress-filtering=no name=BRIDGE-LAN protocol-mode=none vlan-filtering=\
    yes
/interface ethernet
set [ find default-name=ether1 ] comment=\
    "Connected to ISP Router ether4. On Backend Router is ether1" name=\
    UPLINK-A
/interface vlan
add interface=BRIDGE-LAN name=VLAN10-MGMT vlan-id=10
add interface=BRIDGE-LAN name=VLAN20-SERVERS vlan-id=20
add interface=BRIDGE-LAN name=VLAN30-USERS vlan-id=30
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=DHCP_Pool_B ranges=172.26.32.100-172.26.32.254
add name=DHCP_VLAN10 ranges=172.26.10.100-172.26.10.254
add name=DHCP_VLAN20 ranges=172.26.20.100-172.26.20.254
add name=DHCP_VLAN30 ranges=172.26.30.100-172.26.30.254
add name=POOL-SERVER ranges=172.26.32.100-172.26.32.200
/ip dhcp-server
add address-pool=DHCP_Pool_B interface=BRIDGE-LAN name=DHCP-B
add address-pool=DHCP_VLAN10 interface=VLAN10-MGMT name=DHCP-VLAN10
add address-pool=DHCP_VLAN20 interface=VLAN20-SERVERS name=DHCP-VLAN20
add address-pool=DHCP_VLAN30 interface=VLAN30-USERS name=DHCP-VLAN30
/port
set 0 name=serial0
set 1 name=serial1
/routing bgp template
set default disabled=yes output.network=bgp-networks
/interface bridge port
add bridge=BRIDGE-LAN interface=ether2
add bridge=BRIDGE-LAN interface=ether3 pvid=10
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface bridge vlan
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,ether2 untagged=ether3 vlan-ids=10
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,ether2 vlan-ids=20
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,ether2 vlan-ids=30
/interface detect-internet
set wan-interface-list=all
/ip address
add address=172.26.40.2/30 interface=UPLINK-A network=172.26.40.0
add address=172.26.32.1/24 interface=BRIDGE-LAN network=172.26.32.0
add address=172.26.10.1/24 comment="VLAN10 GW" interface=VLAN10-MGMT network=\
    172.26.10.0
add address=172.26.20.1/24 comment="VLAN20 GW" interface=VLAN20-SERVERS \
    network=172.26.20.0
add address=172.26.30.1/24 comment="VLAN30 GW" interface=VLAN30-USERS \
    network=172.26.30.0
/ip dhcp-server lease
add address=172.26.32.250 mac-address=__REDACTED__ server=DHCP-B \
    use-src-mac=yes
add address=172.26.32.240 mac-address=__REDACTED__ server=DHCP-B
add address=172.26.32.130 client-id=1:58:5:d9:50:30:1 mac-address=__REDACTED__ server=DHCP-B
/ip dhcp-server network
add address=172.26.10.0/24 dns-server=172.26.0.1 gateway=172.26.10.1
add address=172.26.20.0/24 dns-server=172.26.0.1 gateway=172.26.20.1
add address=172.26.30.0/24 dns-server=172.26.0.1 gateway=172.26.30.1
add address=172.26.32.0/24 boot-file-name=netboot.xyz.efi dns-server=\
    172.26.0.1 gateway=172.26.32.1 next-server=172.26.32.250
/ip dns
set allow-remote-requests=yes max-concurrent-queries=1000 \
    max-concurrent-tcp-sessions=200 servers=8.8.8.8,8.8.4.4
/ip firewall filter
add action=accept chain=forward comment=DNS-Out dst-port=53 protocol=udp
add action=accept chain=forward comment=DNS-In protocol=udp src-port=53
add action=log chain=forward log-prefix=DHCP_FORWARD port=67-68 protocol=udp
add action=accept chain=forward comment=Allow-ICMP-forward protocol=icmp
add action=accept chain=input comment=Accept-Established-Input \
    connection-state=established,related
add action=accept chain=input comment=Allow-SSH dst-port=22 protocol=tcp
add action=accept chain=input comment="DHCP Allow 67 in" dst-port=67 \
    protocol=udp
add action=accept chain=forward comment="DHCP Allow 67 forward" dst-port=67 \
    protocol=udp
add action=accept chain=forward comment="DHCP Allow 68 forward" dst-port=68 \
    protocol=udp
add action=accept chain=forward comment=SSH-Forward dst-port=22 protocol=tcp
add action=accept chain=forward comment="Accept established/related" \
    connection-state=established,related
add action=fasttrack-connection chain=forward comment=\
    "FastTrack new connections" connection-state=new hw-offload=yes
add action=accept chain=input comment=DNS-Input-Accept dst-port=53 protocol=\
    udp
add action=log chain=input dst-port=53 log=yes log-prefix="DNS_INPUT_DROP " \
    protocol=udp
add action=accept chain=forward comment="ACCEPT Port 4000 to Final Server" \
    dst-address=172.26.32.250 dst-port=4000 protocol=tcp
add action=accept chain=forward comment="ACCEPT Port 443 to Final Server" \
    disabled=yes dst-address=172.26.32.250 dst-port=443 protocol=tcp
add action=accept chain=forward dst-address=172.26.32.250 dst-port=80 \
    protocol=tcp
add action=accept chain=input dst-address=172.26.32.240 dst-port=7000 \
    protocol=tcp
add action=drop chain=forward comment="Drop invalid connections" \
    connection-state=invalid disabled=yes
add action=accept chain=input comment="Allow DHCP Server" dst-port=67 \
    protocol=udp
add action=accept chain=input comment="Allow DHCP Client" protocol=udp \
    src-port=68
add action=accept chain=forward comment="DHCP Forward to Server" dst-port=67 \
    protocol=udp
add action=accept chain=forward comment="DHCP Response from Server" dst-port=\
    68 protocol=udp
add action=accept chain=input comment=Allow-HTTP-Port-83 dst-port=83 \
    protocol=tcp
add action=accept chain=forward comment=Allow-Internet-Traffic-Outbound \
    connection-state=new out-interface=UPLINK-A
add action=accept chain=forward comment=Allow-VLAN1-to-VLAN10 dst-address=\
    172.26.10.0/24 src-address=172.26.32.0/24
add action=accept chain=forward comment=Allow-VLAN10-to-VLAN1 dst-address=\
    172.26.32.0/24 src-address=172.26.10.0/24
add action=accept chain=input comment=AllowICMPInput protocol=icmp
add action=drop chain=input comment=DefaultDROPInputCatchAll disabled=yes
add action=drop chain=forward comment="Default DROP - Forward Catch-all" \
    disabled=yes
add action=accept chain=forward comment="Allow HTTP to Switch Mgmt" \
    dst-address=172.26.10.250 dst-port=80 protocol=tcp
add action=accept chain=forward comment="Allow HTTPS to Switch Mgmt" \
    dst-address=172.26.10.250 dst-port=443 protocol=tcp
add action=accept chain=forward dst-address=172.26.10.0/24 dst-port=80 \
    protocol=tcp
add action=accept chain=forward connection-state=established,related
/ip firewall nat
add action=masquerade chain=srcnat comment=\
    "Masquerade for Router B LAN Internet" out-interface=UPLINK-A
add action=dst-nat chain=dstnat comment=\
    "Forward HTTPS to Server 172.26.32.250" disabled=yes dst-port=443 \
    in-interface=UPLINK-A protocol=tcp to-addresses=172.26.32.250 to-ports=\
    443
add action=dst-nat chain=dstnat disabled=yes dst-port=80 in-interface=\
    UPLINK-A protocol=tcp to-addresses=172.26.32.250 to-ports=80
add action=dst-nat chain=dstnat comment=\
    "Router B: Forward 4000 to Server 172.26.32.250" disabled=yes dst-port=\
    4000 in-interface=UPLINK-A protocol=tcp to-addresses=172.26.32.250 \
    to-ports=4000
/ip route
add dst-address=0.0.0.0/0 gateway=172.26.40.1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=172.26.0.0/16 port=83
set ssh address=172.26.0.0/16
set winbox address=172.26.0.0/16
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
/system routerboard settings
set enter-setup-on=delete-key
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
