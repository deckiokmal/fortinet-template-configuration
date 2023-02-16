# UNDERLAY NETWORK

config system virtual-switch
    edit "lan"
        set physical-switch "sw0"
        config port
            delete lan4
            delete lan5
        end
    next
end

config system virtual-switch
    edit "lan-Wi-Fi"
        set physical-switch "sw0"
        config port
            edit "lan4"
            next
            edit "lan5"
            next
        end
    next
end

config system interface
    edit "wan1"
        set vdom "root"
        set mode static
        set ip 123.231.217.18/29
        set allowaccess ping https ssh snmp fgfm
        set type physical
        set alias "MAINLINK"
        set role wan
    next
    edit "wan2"
        set vdom "root"
        set mode static
        set ip 192.168.2.2/24
        set allowaccess ping
        set type physical
        set alias "BACKUPLINK"
        set role wan
    next
    edit "lan"
        set vdom "root"
        set ip 192.168.50.254/24
        set allowaccess ping https
        set type hard-switch
        set stp enable
        set alias "INTRANET"
        set role lan
    next
    edit "lan-Wi-Fi"
        set vdom "root"
        set ip 192.168.254.254/24
        set allowaccess ping
        set type hard-switch
        set stp enable
        set alias "INTERNET"
        set role lan
    next
end

config router static
    edit 1
        set gateway 123.231.217.17
        set device "wan1"
        set comment "INTERNET VIA MAINLINK"
    next
    edit 2
        set gateway 192.168.50.254
        set device "wan2"
        set comment "INTERNET VIA BACKUPLINK"
    next
    edit 3
        set dst 61.8.69.62/32
        set gateway 123.231.217.17
        set device "wan1"
        set comment "FMG VIA MAINLINK"
    next
    edit 4
        set dst 10.0.0.0 255.0.0.0
        set distance 254
        set comment "CMAINSS-A-blaCKHOLE"
        set blackhole enable
    next
    edit 5
        set dst 172.16.0.0 255.240.0.0
        set distance 254
        set comment "CMAINSS-B-blaCKHOLE"
        set blackhole enable
    next
    edit 6
        set dst 192.168.0.0 255.255.0.0
        set distance 254
        set comment "CMAINSS-C-blaCKHOLE"
        set blackhole enable
    next
end

#2 OVERMAINY NETWORK

config vpn ipsec phase1-interface
    edit "TUN-MAIN"
        set interface "wan1"
        set mode aggressive
        set peertype any
        set net-device enable
        set proposal aes192-sha256
        set add-route disable
        set localid "TUN-MAIN"
        set dpd on-idle
        set dhgrp 5
        set auto-discovery-receiver enable
        set remote-gw 123.231.217.2
        set psksecret L1nt4s4rt@
        set dpd-retryinterval 10
    next
    edit "TUN-BACKUP"
        set interface "wan2"
        set mode aggressive
        set peertype any
        set net-device enable
        set proposal aes192-sha256
        set add-route disable
        set localid "TUN-BACKUP"
        set dpd on-idle
        set dhgrp 5
        set auto-discovery-receiver enable
        set remote-gw 123.231.163.10
        set psksecret L1nt4s4rt@
        set dpd-retryinterval 10
    next
end

config vpn ipsec phase2-interface
    edit "TUN-MAIN"
        set phase1name "TUN-MAIN"
        set proposal aes192-sha256
        set dhgrp 5
    next
    edit "TUN-BACKUP"
        set phase1name "TUN-BACKUP"
        set proposal aes192-sha256
        set dhgrp 5
    next
end

config system interface
    edit "TUN-MAIN"
        set vdom "root"
        set ip 169.254.50.3 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.50.254 255.255.255.0
        set interface "wan1"
    next
    edit "TUN-BACKUP"
        set vdom "root"
        set ip 169.254.51.3 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.51.254 255.255.255.0
        set interface "wan2"
    next
end

#3 ROUTING

# PREFIX LIST 
config router prefix-list
    edit "PREFIX-LAN"
        config rule
            edit 1
                set prefix 192.168.50.0 255.255.255.0
                unset ge
                unset le
            next
        end
    next
end

#ROUTER COMMUNITY 
config router community-list
    edit "65432:123"
        config rule
            edit 1
                set action permit
                set match "65432:123"
            next
        end
    next
end

# ROUTE MAP 
 config router route-map
    edit "OUT-TO-HUB"
        config rule
            edit 10
                set match-ip-address "PREFIX-LAN"
                set set-community "65432:123"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
            next
        end
    next
    edit "IN-FROM-HUB-MAIN"
        config rule
            edit 1
                set match-community "65432:123"
                set set-ip-nexthop 169.254.50.254
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
                set set-route-tag 65432123
            next
        end
    next
    edit "IN-FROM-HUB-BACKUP"
        config rule
            edit 1
                set match-community "65432:123"
                set set-ip-nexthop 169.254.51.254
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
                set set-route-tag 65432123
            next
        end
    next
end

#ROUTER BGP
config router bgp
    set as 65432
    set router-id 192.168.50.254
    set ibgp-multipath enable
    config neighbor
        edit "169.254.50.254"
            set remote-as 65432
            set route-map-in "IN-FROM-HUB-MAIN"
            set route-map-out "OUT-TO-HUB"
            set connect-timer 1
        next
        edit "169.254.51.254"
            set remote-as 65432
            set route-map-in "IN-FROM-HUB-BACKUP"
            set route-map-out "OUT-TO-HUB"
            set connect-timer 1
        next
    end
    config network
        edit 1
            set prefix 192.168.50.0 255.255.255.0
        next
    end
end

#FIREWALL ADDRESSES 
config firewall address
    edit "ip.192"
        set allow-routing enable
        set subnet 192.168.0.0 255.255.0.0
    next
end

config firewall addrgrp
        edit "svr-dc"
        set member "ip.192"
        set allow-routing enable
    next
end

# SDWAN
config system virtual-wan-link
    set status enable
    config members
        edit 1
            set interface "TUN-MAIN"
            set gateway 169.254.50.254
            set source 192.168.50.254
        next
        edit 2
            set interface "TUN-BACKUP"
            set gateway 169.254.51.254
            set source 192.168.50.254
        next
    end
    config service
        edit 1
            set name "INTRANET"
            set mode manual
            set dst "svr-dc"
            set src "all"
            set priority-members 1 2
        next
    end
end

# FIREWALL POLICY 
config firewall policy
    edit 1
        set name "SPOKE-TO-HUB"
        set srcintf "lan"
        set dstintf "virtual-wan-link"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set fsso disable
        set nat disable
    next
    
    edit 2
        set name "HUB-TO-SPOKE"
        set srcintf "virtual-wan-link"
        set dstintf "lan"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set fsso disable
        set nat disable
    next
    edit 3
        set name "INTERNET-WIFI"
        set srcintf "lan-Wi-Fi"
        set dstintf "wan1" "wan2"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set fsso disable
        set nat enable
    next
end
