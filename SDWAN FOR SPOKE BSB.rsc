config system virtual-switch
    edit "lan"
        set physical-switch "sw0"
        config port
            delete "lan3"
            next
        end
    next
end

config system interface
    edit "wan"
        set vdom "root"
        set mode static
        set ip 1.11.7.62 255.255.255.252
        set allowaccess ping https ssh snmp telnet
        set type physical
        set alias "MAIN"
        set role wan
    next
    edit "lan3"
        set vdom "root"
        set mode dhcp
        set allowaccess ping fgfm
        set type physical
        set alias "BACKUP"
        set lldp-reception enable
        set role wan
    next
    edit "lan"
        set vdom "root"
        set ip 172.21.10.201 255.255.255.248
        set allowaccess ping https ssh snmp telnet
        set type hard-switch
        set alias "LAN"
        set stp enable
        set role lan
        set secondary-IP enable
        config secondaryip
            edit 1
                set ip 1.5.206.23 255.255.255.255
                set allowaccess ping https ssh snmp telnet
            next
        end
    next
end

config router static
    edit 1
        set dst 1.2.69.104 255.255.255.252
        set gateway 1.11.7.61
        set comment "HUB-IPVPN"
        set device "wan"
    next
    edit 2
        set dst 123.231.246.74 255.255.255.255
        set device "lan3"
        set comment "HUB-INET"
        set dynamic-gateway enable
    next
    edit 3
        set dst 61.8.69.62 255.255.255.255
        set device "lan3"
        set comment "FMG-01"
        set dynamic-gateway enable
    next
    edit 4
        set dst 202.152.25.234 255.255.255.255
        set device "lan3"
        set comment "FMG-02"
        set dynamic-gateway enable
    next
end

config vpn ipsec phase1-interface
    edit "SPOKE-IPVPN"
        set interface "wan"
        set mode aggressive
        set peertype any
        set net-device enable
        set proposal aes192-sha256
        set localid "ipvpn-peer"
        set dpd on-idle
        set dhgrp 5
        set remote-gw 1.2.69.106
        set psksecret ENC BKv/+USBys0Ap1/xXsu2Eg52dSCsKpx0AsV25tv0JJ+x/JKFTiXHP1F1HHFKG9ZORSvcA73CapQhJcTEhOqV9jmn8PVV8G0GZnzUA91USJZzaqmsc7DVK3cWfrSeJdCF2eTsvaupwwYJ+eeRdM2FS1lidivRCja3escEa/gftWIsyCqZjxHEX+Pv1SRWkOQIvRTyTQ==
        set dpd-retryinterval 60
    next
    edit "SPOKE-INET"
        set interface "lan3"
        set mode aggressive
        set peertype any
        set net-device enable
        set proposal aes192-sha256
        set localid "inet-peer"
        set dpd on-idle
        set dhgrp 5
        set remote-gw 123.231.246.74
        set psksecret ENC I+UybCNMY+uC6u2Z1TdNFADlc8gV7lxJsmaXCQm3JOnhwAQpxlYytcDSmMO76KdhILrcxqxwUFXPBZps/UnoHD2br6QIvGcBRTKd3lr20gS8LBDoc3HBw7/zxtMuIWxh1eoJXS6uT3h/UOwh173ccpJdmiKDiQ57ffeZFBYW6LgfjoLELwv2DpFkWsQ/0D/AKkLudg==
        set dpd-retryinterval 60
    next
end
config vpn ipsec phase2-interface
    edit "SPOKE-IPVPN"
        set phase1name "SPOKE-IPVPN"
        set proposal aes192-sha256
        set dhgrp 5
    next
    edit "SPOKE-INET"
        set phase1name "SPOKE-INET"
        set proposal aes192-sha256
        set dhgrp 5
    next
end

config system interface
    edit "SPOKE-IPVPN"
        set vdom "root"
        set ip 169.254.253.23 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.253.254 255.255.255.0
    next
    edit "SPOKE-INET"
        set vdom "root"
        set ip 169.254.254.23 255.255.255.255
        set allowaccess ping telnet
        set type tunnel
        set remote-ip 169.254.254.254 255.255.255.0
    next
end

config router bgp
    set as 65507
    set router-id 172.21.10.201
    set ibgp-multipath enable
    config neighbor
        edit "169.254.253.254"
            set advertisement-interval 1
            set link-down-failover enable
            set next-hop-self enable
            set soft-reconfiguration enable
            set remote-as 65507
        next
        edit "169.254.254.254"
            set advertisement-interval 1
            set link-down-failover enable
            set next-hop-self enable
            set soft-reconfiguration enable
            set remote-as 65507
        next
    end
    config network
        edit 1
            set prefix 1.5.206.23 255.255.255.255
        next
        edit 2
            set prefix 172.21.10.200 255.255.255.248
        next
    end
end

config system sdwan
    set status enable
    config zone
        edit "LOWEST-COST-ZONE"
        next
    end
    config members
        edit 1
            set interface "SPOKE-IPVPN"
            set zone "LOWEST-COST-ZONE"
            set gateway 169.254.253.254
            set source 172.21.10.201
        next
        edit 2
            set interface "SPOKE-INET"
            set zone "LOWEST-COST-ZONE"
            set gateway 169.254.254.254
            set source 172.21.10.201
            set cost 1
        next
    end
    config health-check
        edit "BACKHAUL"
            set server "123.231.209.41"
            set members 0
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 100
                    set packetloss-threshold 5
                next
            end
        next
    end
    config service
        edit 1
            set name "FAILOVER-STRATEGY"
            set mode sla
            set dst "all"
            set src "all"
            config sla
                edit "BACKHAUL"
                    set id 1
                next
            end
            set priority-members 1 2
        next
    end
end

config firewall policy
    edit 1
        set name "SPOKE-TO-HUB"
        set srcintf "lan"
        set dstintf "LOWEST-COST-ZONE"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat disable
    next
    edit 2
        set name "HUB-TO-SPOKE"
        set srcintf "LOWEST-COST-ZONE"
        set dstintf "lan"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set nat disable
    next
end

