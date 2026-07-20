# 2026-07-20 16:31:00 by RouterOS 7.20.6
# software id = 7V74-E806
#
# model = RB4011iGS+
# serial number = __REDACTED__
/interface bridge
add name=ETH-BRIDGE
/interface ethernet
set [ find default-name=ether1 ] name=WAN
/interface vlan
add interface=WAN name=VLAN_DIGI vlan-id=20
/interface pppoe-client
add add-default-route=yes comment="Interface ONT" disabled=no interface=\
    VLAN_DIGI name=Digi password=__REDACTED__ use-peer-dns=yes user=__REDACTED__
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=172.26.0.2-172.26.31.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ETH-BRIDGE name=dhcp1
/port
set 0 name=serial0
set 1 name=serial1
/interface bridge port
add bridge=ETH-BRIDGE interface=ether2
add bridge=ETH-BRIDGE interface=ether3
add bridge=ETH-BRIDGE interface=ether5
add bridge=ETH-BRIDGE interface=ether6
add bridge=ETH-BRIDGE interface=ether7
add bridge=ETH-BRIDGE interface=ether8
add bridge=ETH-BRIDGE interface=ether9
add bridge=ETH-BRIDGE interface=ether10
/ip address
add address=172.26.0.1/19 interface=ETH-BRIDGE network=172.26.0.0
add address=172.26.40.1/30 comment="Link to Router B" interface=ether4 \
    network=172.26.40.0
/ip dhcp-server lease
add address=172.26.0.150 client-id=1:0:16:96:ec:13:b4 mac-address=__REDACTED__ server=dhcp1
add address=172.26.0.25 client-id=1:dc:a6:32:c5:f5:9d mac-address=__REDACTED__ server=dhcp1
add address=172.26.32.130 mac-address=__REDACTED__
/ip dhcp-server network
add address=172.26.0.0/19 boot-file-name=netboot.xyz.lkrn dns-server=\
    172.26.0.1 gateway=172.26.0.1 next-server=172.26.32.250
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.1.1
/ip dns static
add address=172.26.32.250 name=registry.martinez-saweczko.es type=A
add address=172.26.32.250 name=periodico.martinez-saweczko.es type=A
add address=172.26.0.25 comment=pi name=pi.martinez-saweczko.es type=A
add address=172.26.32.250 comment="DNS for Print" name=\
    impresora.martinez-saweczko.es type=A
/ip firewall filter
add action=accept chain=input comment="01. Allow Established/Related" \
    connection-state=established,related
add action=drop chain=input comment="02. Drop Invalid Connections" \
    connection-state=invalid
add action=add-src-to-address-list address-list=API_blacklist \
    address-list-timeout=1w chain=input connection-state=new dst-port=8728 \
    protocol=tcp src-address-list=API_temp_list
add action=add-src-to-address-list address-list=API_temp_list \
    address-list-timeout=1m chain=input connection-state=new dst-port=8728 \
    limit=5,5:packet protocol=tcp
add action=drop chain=input comment="Drop API Brute Force Attempts" \
    src-address-list=API_blacklist
add action=accept chain=input comment="03. Allow LAN Access to Router" \
    in-interface=ETH-BRIDGE
add action=fasttrack-connection chain=forward comment=\
    "FastTrack Established/Related" connection-state=established,related \
    hw-offload=yes
add action=drop chain=forward comment="06. Drop Invalid Connections" \
    connection-state=invalid
add action=accept chain=forward comment=\
    "Allow WAN published services to rack server" connection-state=new \
    dst-address=172.26.32.250 dst-port=443,4000,80 in-interface=Digi \
    protocol=tcp
add action=drop chain=forward comment=\
    "07. Drop all other traffic to LAN from WAN" connection-state=new \
    in-interface=Digi
add action=accept chain=forward comment="Allow Dst-NAT'd traffic to Router B" \
    connection-state=new disabled=yes dst-address=172.26.40.2 dst-port=4000 \
    in-interface=Digi protocol=tcp
add action=accept chain=forward comment="Allow Dst-NAT: HTTPS to Router B" \
    connection-state=new disabled=yes dst-address=172.26.40.2 dst-port=443 \
    in-interface=Digi protocol=tcp
add action=accept chain=forward connection-state=new disabled=yes \
    dst-address=172.26.40.2 dst-port=80 in-interface=Digi protocol=tcp
add action=drop chain=input comment=\
    "04. Drop all other traffic to router from WAN" connection-state=new \
    in-interface=Digi
add action=log chain=forward comment="Log dropped WAN forward traffic" \
    log-prefix="WAN_FWD_DROP: "
/ip firewall nat
add action=masquerade chain=srcnat out-interface=Digi
add action=dst-nat chain=dstnat comment="Forward HTTPS to Router B Uplink" \
    disabled=yes dst-port=443 in-interface=Digi protocol=tcp to-addresses=\
    172.26.40.2 to-ports=443
add action=dst-nat chain=dstnat disabled=yes dst-port=80 in-interface=Digi \
    protocol=tcp to-addresses=172.26.40.2 to-ports=80
add action=dst-nat chain=dstnat comment=\
    "Router A: Forward 4000 to Router B Uplink" disabled=yes dst-port=4000 \
    in-interface=Digi protocol=tcp to-addresses=172.26.40.2 to-ports=4000
add action=dst-nat chain=dstnat comment="WAN 443 -> 172.26.32.250" dst-port=\
    443,80 in-interface=Digi protocol=tcp to-addresses=172.26.32.250 \
    to-ports=443
add action=dst-nat chain=dstnat comment="WAN 4000 -> 172.26.32.250" dst-port=\
    4000 in-interface=Digi protocol=tcp to-addresses=172.26.32.250 to-ports=\
    4000
/ip route
add dst-address=172.26.32.0/24 gateway=172.26.40.2
add comment="Habitacion David MGMT" disabled=no distance=1 dst-address=\
    172.26.10.0/24 gateway=172.26.40.2 routing-table=main \
    suppress-hw-offload=no
add comment="Habitacion David  SERVERS" disabled=no distance=1 dst-address=\
    172.26.20.0/24 gateway=172.26.40.2 routing-table=main \
    suppress-hw-offload=no
add comment="Habitacion David  USERS" disabled=no distance=1 dst-address=\
    172.26.30.0/24 gateway=172.26.40.2 routing-table=main \
    suppress-hw-offload=no
/ip service
set ftp disabled=yes
set ssh address=172.26.0.0/16
set telnet disabled=yes
set www address=172.26.0.0/16 port=83
set winbox address=172.26.0.0/16
set api disabled=yes
/system clock
set time-zone-name=Europe/Madrid
/system identity
set name="Internet Router"
/system ntp client
set enabled=yes
/system ntp client servers
add address=es.pool.ntp.org
/system scheduler
add disabled=yes interval=1d name=nightly_reboot on-event="/system reboot" \
    policy=reboot,read,write,policy start-date=2026-05-10 start-time=03:00:00
