# UNDERLAY NETWORK
config system interface
    edit "wan1"
        set vdom "root"
        set mode static
        set ip 123.231.217.2/29
        set allowaccess ping https ssh snmp fgfm
        set type physical
        set alias "MAINLINK"
        set role wan
    next
    edit "wan2"
        set vdom "root"
        set mode static
        set ip 123.231.163.10/29
        set allowaccess ping https ssh snmp fgfm
        set type physical
        set alias "BACKUPLINK"
        set role wan
    next
    edit "lan"
        set vdom "root"
        set ip 172.10.1.2/30
        set allowaccess ping https
        set type hard-switch
        set stp enable
        set alias "INTRANET"
        set role lan
    next
end

config system virtual-wan-link
    set status enable
    config members
        edit 1
            set interface "wan1"
            set gateway 123.231.217.1
        next
        edit 2
            set interface "wan2"
            set gateway 123.231.163.9
        next
    end
end

config router static
    edit 1
        set distance 1
        set comment "GATEWAY HUB"
        set virtual-wan-link enable
    next
    edit 2
        set dst 192.168.0.0/24
        set gateway 172.10.1.1
        set device "lan"
        set comment "INTRANET"
    next
end

# OVERLAY NETWORK

config vpn ipsec phase1-interface
    edit "TUN-MAIN"
        set type dynamic
        set interface "wan1"
        set local-gw 123.231.217.2
        set mode aggressive
        set peertype one
        set net-device disable
        set proposal aes192-sha256
        set add-route disable
        set dpd on-idle
        set dhgrp 5
        set auto-discovery-sender enable
        set peerid "TUN-MAIN"
        set tunnel-search nexthop
        set psksecret L1nt4s4rt@
        set dpd-retryinterval 10
    next
     edit "TUN-BACKUP"
        set type dynamic
        set interface "wan2"
        set local-gw 123.231.163.10
        set mode aggressive
        set peertype one
        set net-device disable
        set proposal aes192-sha256
        set add-route disable
        set dpd on-idle
        set dhgrp 5
        set auto-discovery-sender enable
        set peerid "TUN-BACKUP"
        set tunnel-search nexthop
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
        set ip 169.254.50.254 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.50.253 255.255.255.0
        set interface "wan1"
    next
    edit "TUN-BACKUP"
        set vdom "root"
        set ip 169.254.51.254 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.51.253 255.255.255.0
        set interface "wan2"
    next
end

# ROUTING

#STATIC
config router static
    edit 3
        set dst 10.0.0.0 255.0.0.0
        set distance 254
        set comment "CLASS-A-BLACKHOLE"
        set blackhole enable
    next  
    edit 4
        set dst 172.16.0.0 255.240.0.0
        set distance 254
        set comment "CLASS-B-BLACKHOLE"
        set blackhole enable
    next  
    edit 5
        set dst 192.168.0.0 255.255.0.0
        set distance 254
        set comment "BLACKHOLE-CLASS-C"
        set blackhole enable
    next
end

#ROUTING POLICY
config router policy
    edit 1
        set input-device "TUN-MAIN"
        set src "192.168.0.0/255.255.0.0"
        set dst "192.168.0.0/255.255.0.0"
        set output-device "TUN-MAIN"
    next
    edit 2
        set input-device "TUN-BACKUP"
        set src "192.168.0.0/255.255.0.0"
        set dst "192.168.0.0/255.255.0.0"
        set output-device "TUN-BACKUP"
    next
end

#PREFIX ADDRESS
config router prefix-list
    edit "PREFIX-TO-SPOKE"
        config rule
            edit 1
                set prefix 172.10.1.0 255.255.255.252
                unset ge
                unset le
            next
            edit 2
                set prefix 192.168.0.0 255.255.255.0
                unset ge
                unset le
            next
            edit 3
                set prefix 192.168.1.0 255.255.255.0
                unset ge
                unset le
            next
            edit 4
                set prefix 192.168.2.0 255.255.255.0
                unset ge
                unset le
            next
            edit 5
                set prefix 192.168.3.0 255.255.255.0
                unset ge
                unset le
            next
            edit 6
                set prefix 192.168.4.0 255.255.255.0
                unset ge
                unset le
            next
            edit 7
                set prefix 192.168.5.0 255.255.255.0
                unset ge
                unset le
            next
            edit 8
                set prefix 192.168.6.0 255.255.255.0
                unset ge
                unset le
            next
            edit 9
                set prefix 192.168.10.0 255.255.255.0
                unset ge
                unset le
            next
            edit 10
                set prefix 192.168.14.0 255.255.255.0
                unset ge
                unset le
            next
            edit 11
                set prefix 192.168.16.0 255.255.255.0
                unset ge
                unset le
            next
            edit 12
                set prefix 192.168.17.0 255.255.255.0
                unset ge
                unset le
            next
            edit 13
                set prefix 192.168.18.0 255.255.255.0
                unset ge
                unset le
            next
            edit 14
                set prefix 192.168.50.0 255.255.255.0
                unset ge
                unset le
            next
            edit 15
                set prefix 192.168.60.0 255.255.255.0
                unset ge
                unset le
            next
            edit 16
                set prefix 192.168.61.0 255.255.255.0
                unset ge
                unset le
            next
            edit 17
                set prefix 192.168.100.0 255.255.255.0
                unset ge
                unset le
            next
        end
    next
end

#ROUTER COMMUNITY LIST
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

#ROUTE MAP for BGP
config router route-map
    edit "OUT-TO-ADVPN-SPOKE"
        config rule
            edit 1
                set match-ip-address "PREFIX-TO-SPOKE"
                set set-community "65432:123"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
            next
            edit 2
                set match-community "65432:123"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
            next
        end
    next
end

#ROUTING BGP
config router bgp
    set as 65432
    set router-id 172.10.1.2
    set ibgp-multipath enable
    config neighbor-group
        edit "TUN-MAIN"
            set link-down-failover enable
            set next-hop-self enable
            set remote-as 65432
            set route-map-out "OUT-TO-ADVPN-SPOKE"
            set keep-alive-timer 4
            set holdtime-timer 12
            set route-reflector-client enable
        next
        edit "TUN-BACKUP"
            set link-down-failover enable
            set next-hop-self enable
            set remote-as 65432
            set route-map-out "OUT-TO-ADVPN-SPOKE"
            set keep-alive-timer 4
            set holdtime-timer 12
            set route-reflector-client enable
        next
    end
    config neighbor-range
        edit 1
            set prefix 169.254.50.0 255.255.255.0
            set neighbor-group "TUN-MAIN"
        next
        edit 2
            set prefix 169.254.51.0 255.255.255.0
            set neighbor-group "TUN-BACKUP"
        next
    end
    config network
        edit 1
            set prefix 172.10.1.0 255.255.255.252
        next
        edit 2
            set prefix 192.168.0.0 255.255.255.0
        next
        edit 3
            set prefix 192.168.1.0 255.255.255.0
        next
        edit 4
            set prefix 192.168.2.0 255.255.255.0
        next
        edit 5
            set prefix 192.168.3.0 255.255.255.0
        next
        edit 6
            set prefix 192.168.4.0 255.255.255.0
        next
        edit 7
            set prefix 192.168.5.0 255.255.255.0
        next
        edit 8
            set prefix 192.168.6.0 255.255.255.0
        next
        edit 9
            set prefix 192.168.10.0 255.255.255.0
        next
        edit 10
            set prefix 192.168.14.0 255.255.255.0
        next
        edit 11
            set prefix 192.168.16.0 255.255.255.0
        next
        edit 12
            set prefix 192.168.17.0 255.255.255.0
        next
        edit 13
            set prefix 192.168.18.0 255.255.255.0
        next
        edit 14
            set prefix 192.168.50.0 255.255.255.0
        next
        edit 15
            set prefix 192.168.60.0 255.255.255.0
        next
        edit 16
            set prefix 192.168.61.0 255.255.255.0
        next
        edit 17
            set prefix 192.168.100.0 255.255.255.0
        next
    end
end

# FIREWALL POLICY
config firewall policy
    edit 1
        set name "HUB-TO-SPOKE"
        set srcintf "lan"
        set dstintf "TUN-BACKUP" "TUN-MAIN"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat disable
    next
    edit 2
        set name "SPOKE-TO-HUB"
        set srcintf "TUN-BACKUP" "TUN-MAIN"
        set dstintf "lan"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat disable
        next
     edit 3
        set name "SPOKE-TO_SPOKE"
        set srcintf "TUN-BACKUP" "TUN-MAIN"
        set dstintf "TUN-BACKUP" "TUN-MAIN"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat disable
    next
end
