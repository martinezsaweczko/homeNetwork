# 2026-08-01 11:48:45 by RouterOS 7.23.2
# software id = JCZK-M2GK
#
# model = RB4011iGS+
# serial number = __REDACTED__
/interface bridge
add igmp-snooping=yes ingress-filtering=no name=BRIDGE-LAN port-cost-mode=\
    short protocol-mode=none vlan-filtering=yes
/interface ethernet
set [ find default-name=ether1 ] comment=\
    "Connected to ISP Router ether4. On Backend Router is ether1" name=\
    UPLINK-A
/interface vlan
add interface=BRIDGE-LAN name=VLAN10-MGMT vlan-id=10
add interface=BRIDGE-LAN name=VLAN20-SERVERS vlan-id=20
add interface=BRIDGE-LAN name=VLAN30-USERS vlan-id=30
/interface bonding
add mode=balance-xor name=LAG-SWITCH-V2 slaves=ether7,ether8,ether9,ether10
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
add address-pool=DHCP_Pool_B interface=BRIDGE-LAN lease-time=10m name=DHCP-B
add address-pool=DHCP_VLAN10 interface=VLAN10-MGMT lease-time=10m name=\
    DHCP-VLAN10
add address-pool=DHCP_VLAN30 interface=VLAN30-USERS lease-time=10m name=\
    DHCP-VLAN30
add address-pool=DHCP_VLAN20 interface=VLAN20-SERVERS lease-time=10m name=\
    DHCP-VLAN20
/ip smb users
set [ find default=yes ] disabled=yes
/routing bgp template
set default disabled=yes output.network=bgp-networks
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
/interface bridge port
add bridge=BRIDGE-LAN ingress-filtering=no interface=ether2 \
    internal-path-cost=10 path-cost=10 pvid=10
add bridge=BRIDGE-LAN ingress-filtering=no interface=ether3 \
    internal-path-cost=10 path-cost=10 pvid=10
add bridge=BRIDGE-LAN hw=no ingress-filtering=no interface=LAG-SWITCH-V2 \
    internal-path-cost=10 path-cost=10
add bridge=BRIDGE-LAN interface=ether5 internal-path-cost=10 path-cost=10 \
    pvid=20
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192 soft-max-neighbor-entries=8191
/interface bridge vlan
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,LAG-SWITCH-V2 untagged=ether2,ether3 \
    vlan-ids=10
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,LAG-SWITCH-V2 vlan-ids=30
add bridge=BRIDGE-LAN tagged=BRIDGE-LAN,LAG-SWITCH-V2 untagged=ether5 \
    vlan-ids=20
/interface detect-internet
set wan-interface-list=all
/interface ovpn-server server
add mac-address=__REDACTED__ name=ovpn-server1
/ip address
add address=172.26.40.2/30 interface=UPLINK-A network=172.26.40.0
add address=172.26.32.1/24 interface=BRIDGE-LAN network=172.26.32.0
add address=172.26.10.1/24 comment="VLAN10 GW" interface=VLAN10-MGMT network=\
    172.26.10.0
add address=172.26.30.1/24 comment="VLAN30 GW" interface=VLAN30-USERS \
    network=172.26.30.0
add address=172.26.20.1/24 interface=VLAN20-SERVERS network=172.26.20.0
/ip dhcp-server lease
add address=172.26.32.240 mac-address=__REDACTED__ server=DHCP-B
add address=172.26.32.130 client-id=1:58:5:d9:50:30:1 mac-address=__REDACTED__ server=DHCP-B
add address=172.26.20.250 comment="Fedora Server VLAN20" mac-address=__REDACTED__ server=*9 use-src-mac=yes
add address=172.26.20.249 comment=server.martinez-saweczko.es mac-address=__REDACTED__ server=DHCP-VLAN20
add address=172.26.10.249 client-id=1:48:da:35:6f:8:52 comment=\
    serverkvm.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN10
add address=172.26.10.248 client-id=1:48:da:35:6f:ce:1c comment=\
    k8s1kvm.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN10
add address=172.26.20.248 client-id=1:0:e0:4c:73:3c:34 comment=\
    k8s1.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN20
add address=172.26.10.247 client-id=1:48:da:35:6f:b5:e4 comment=\
    k8s2kvm.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN10
add address=172.26.20.247 client-id=1:e8:ff:1e:d9:44:f3 comment=\
    k8s2.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN20
add address=172.26.10.246 client-id=1:e:8f:aa:96:2b:c5 comment=\
    k8s3kvm.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN10
add address=172.26.20.246 client-id=1:0:e0:4c:45:cd:27 comment=\
    k8s3kvm.martinez-saweczko.es mac-address=__REDACTED__ server=\
    DHCP-VLAN20
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
    "FastTrack new connections" connection-state=new
add action=accept chain=input comment=DNS-Input-Accept dst-port=53 protocol=\
    udp
add action=log chain=input dst-port=53 log=yes log-prefix="DNS_INPUT_DROP " \
    protocol=udp
add action=accept chain=forward comment="ACCEPT Port 4000 to Final Server" \
    dst-address=172.26.20.254 dst-port=4000 protocol=tcp
add action=accept chain=forward comment="ACCEPT Port 443 to Final Server" \
    dst-address=172.26.20.254 dst-port=443 protocol=tcp
add action=accept chain=forward dst-address=172.26.20.254 dst-port=80 \
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
add action=accept chain=forward dst-address=172.26.10.0/24 in-interface=\
    UPLINK-A
add action=accept chain=forward in-interface=VLAN10-MGMT out-interface=\
    UPLINK-A
add action=accept chain=forward dst-address=172.26.10.0/24 src-address=\
    172.26.0.0/16
add action=accept chain=forward comment=Allow-VLAN20-to-VLAN1 dst-address=\
    172.26.32.0/24 src-address=172.26.20.0/24
add action=accept chain=forward comment=Allow-VLAN1-to-VLAN20 dst-address=\
    172.26.20.0/24 src-address=172.26.32.0/24
add action=accept chain=forward comment=Allow-VLAN20-to-VLAN10 dst-address=\
    172.26.10.0/24 src-address=172.26.20.0/24
add action=accept chain=forward comment=Allow-VLAN10-to-VLAN20 dst-address=\
    172.26.20.0/24 src-address=172.26.10.0/24
add action=accept chain=forward comment="Allow from ISP to VLAN20 via uplink" \
    dst-address=172.26.20.0/24 in-interface=UPLINK-A
add action=accept chain=forward comment="Allow ISP network to VLAN20" \
    dst-address=172.26.20.0/24 src-address=172.26.0.0/16
add action=accept chain=forward comment="Allow from ISP to VLAN30 via uplink" \
    dst-address=172.26.30.0/24 in-interface=UPLINK-A
add action=accept chain=forward comment="Allow ISP network to VLAN30" \
    dst-address=172.26.30.0/24 src-address=172.26.0.0/16
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
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add dst-address=0.0.0.0/0 gateway=172.26.40.1
/ip service
set ftp disabled=yes
set ssh address=172.26.0.0/16
set telnet disabled=yes
set www address=172.26.0.0/16 port=83
set winbox address=172.26.0.0/16
/ipv6 nd
set [ find default=yes ] advertise-dns=yes
/system clock
set time-zone-name=Europe/Madrid
/system identity
set name=MikroRouter
/system logging
add topics=dhcp
add prefix=VLAN20_TEST topics=dhcp
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
/tool bandwidth-server
set authenticate=no
/tool graphing interface
add
