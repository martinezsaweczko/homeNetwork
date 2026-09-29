# 2026-09-29 19:27:04 by RouterOS 7.23.2
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
add name=dhcp_pool0 ranges=172.26.0.2-172.26.0.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ETH-BRIDGE name=dhcp1
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
add address=172.26.0.1/24 interface=ETH-BRIDGE network=172.26.0.0
add address=172.26.40.1/30 comment="Link to Router B" interface=ether4 \
    network=172.26.40.0
/ip dhcp-server lease
add address=172.26.0.150 client-id=1:0:16:96:ec:13:b4 mac-address=__REDACTED__ server=dhcp1
add address=172.26.0.25 client-id=1:dc:a6:32:c5:f5:9d mac-address=__REDACTED__ server=dhcp1
add address=172.26.0.130 mac-address=__REDACTED__
/ip dhcp-server network
add address=172.26.0.0/24 boot-file-name=netboot.xyz.lkrn dns-server=\
    172.26.0.1 gateway=172.26.0.1 next-server=172.26.32.250
/ip dns
set allow-remote-requests=yes servers=172.26.20.37,8.8.1.1
/ip dns static
add cname=server.martinez-saweczko.es name=registry.martinez-saweczko.es \
    type=CNAME
add cname=server.martinez-saweczko.es name=periodico.martinez-saweczko.es \
    type=CNAME
add address=172.26.0.25 comment=pi name=pi.martinez-saweczko.es type=A
add cname=server.martinez-saweczko.es comment="DNS for Print" name=\
    impresora.martinez-saweczko.es type=CNAME
add address=172.26.20.249 name=server.martinez-saweczko.es type=A
add address=172.26.10.249 name=serverkvm.martinez-saweczko.es type=A
add address=172.26.10.248 name=k8s1kvm.martinez-saweczko.es type=A
add address=172.26.20.248 name=k8s1.martinez-saweczko.es type=A
add address=172.26.20.247 name=k8s2.martinez-saweczko.es type=A
add address=172.26.10.247 name=k8s2kvm.martinez-saweczko.es type=A
add address=172.26.20.246 comment=k8s3.martinez-saweczko.es name=\
    k8s3.martinez-saweczko.es type=A
add address=172.26.10.246 comment=k8s3kvm.martinez-saweczko.es name=\
    k8s3kvm.martinez-saweczko.es type=A
add address=172.26.20.34 comment=Grafana name=grafana.martinez-saweczko.es \
    type=A
add address=172.26.20.35 comment=MySQL name=mysql.martinez-saweczko.es type=A
add address=172.26.20.36 comment=Netflow name=netflow.martinez-saweczko.es \
    type=A
add address=172.26.20.34 comment=PiHole name=pihole.martinez-saweczko.es \
    type=A
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
    "FastTrack Established/Related" connection-state=established,related
add action=accept chain=forward comment="Allow LAN to VLAN10" dst-address=\
    172.26.10.0/24 src-address=172.26.0.0/19
add action=accept chain=forward comment="Allow LAN to VLAN20" dst-address=\
    172.26.20.0/24 src-address=172.26.0.0/19
add action=accept chain=forward comment="Allow LAN to VLAN30" dst-address=\
    172.26.30.0/24 src-address=172.26.0.0/19
add action=accept chain=forward comment=\
    "Allow WAN published services to rack server" connection-state=new \
    dst-address=172.26.20.249 dst-port=443,4000,80 in-interface=Digi \
    protocol=tcp
add action=drop chain=forward comment="06. Drop Invalid Connections" \
    connection-state=invalid
add action=accept chain=forward comment="Allow WireGuard to Backend" \
    connection-state=new dst-address=172.26.40.2 dst-port=51820 in-interface=\
    Digi protocol=udp
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
add action=dst-nat chain=dstnat comment="WAN 443 -> 172.26.32.250" disabled=\
    yes dst-port=443,80 in-interface=Digi protocol=tcp to-addresses=\
    172.26.32.250 to-ports=443
add action=dst-nat chain=dstnat comment="WAN 4000 -> 172.26.32.250" disabled=\
    yes dst-port=4000 in-interface=Digi protocol=tcp to-addresses=\
    172.26.32.250 to-ports=4000
add action=dst-nat chain=dstnat comment=\
    "WAN 443 -> 172.26.20.249 (VLAN20 Webserver)" dst-port=443,4000 \
    in-interface=Digi protocol=tcp to-addresses=172.26.20.249 to-ports=443
add action=dst-nat chain=dstnat comment="WireGuard to Backend" dst-port=51820 \
    in-interface=Digi protocol=udp to-addresses=172.26.40.2 to-ports=51820
/ip route
add dst-address=172.26.32.0/24 gateway=172.26.40.2
add comment="Habitacion David MGMT" disabled=no distance=1 dst-address=\
    172.26.10.0/24 gateway=172.26.40.2 routing-table=main
add comment="Habitacion David  SERVERS" disabled=no distance=1 dst-address=\
    172.26.20.0/24 gateway=172.26.40.2 routing-table=main
add comment="Habitacion David  USERS" disabled=no distance=1 dst-address=\
    172.26.30.0/24 gateway=172.26.40.2 routing-table=main
add comment="WireGuard VPN subnet" dst-address=172.26.50.0/24 gateway=\
    172.26.40.2
/ip service
set ftp disabled=yes
set ssh address=172.26.0.0/16
set telnet disabled=yes
set www address=172.26.0.0/16 port=83
set winbox address=172.26.0.0/16
set api disabled=yes
/ip traffic-flow
set active-flow-timeout=1m enabled=yes
/ip traffic-flow target
add dst-address=172.26.20.36 version=ipfix
/snmp
set enabled=yes
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
