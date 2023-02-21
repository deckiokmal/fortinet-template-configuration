1. UNDERLAY

2. OVERLAY
config vpn ipsec phase1-interface
    edit "T-MAIN"
        set interface "port2"
        set peertype any
        set exchange-interface-ip enable
        set proposal aes256-sha256
        set dhgrp 5
        set remote-gw 172.16.0.78
        set psksecret L1nt4s4rt@
    next
    edit "T-BACKUP"
        set interface "port3"
        set peertype any
        set exchange-interface-ip enable
        set proposal aes256-sha256
        set dhgrp 5
        set remote-gw 172.16.0.82
        set psksecret L1nt4s4rt@
    next
end

config vpn ipsec phase2-interface
    edit "T-MAIN_p2"
        set phase1name "T-MAIN"
        set proposal aes256-sha256
        set pfs disable
        set replay disable
        set auto-negotiate enable
    next
    edit "T-BACKUP_p2"
        set phase1name "T-BACKUP"
        set proposal aes256-sha256
        set pfs disable
        set replay disable
        set auto-negotiate enable
    next
end

3. ROUTING
config system interface
    edit "T-MAIN"
        set vdom "root"
        set ip 10.254.0.2 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.0.1 255.255.255.255
        set interface "port2"
    next
    edit "T-BACKUP"
        set vdom "root"
        set ip 10.254.1.2 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.1.1 255.255.255.255
        set interface "port3"
    next
end

config router bgp
    set as 65500
    set router-id 10.254.0.2
    set ibgp-multipath enable
    config neighbor
        edit "10.254.0.1"
            set soft-reconfiguration enable
            set remote-as 65500
        next
        edit "10.254.1.1"
            set soft-reconfiguration enable
            set remote-as 65500
        next
    end
end

4. SDWAN
config system sdwan
    set status enable
    config members
        edit 1
            set interface "T-MAIN"
            set source 192.168.1.1
            set gateway 10.254.0.1
        next
        edit 2
            set interface "T-BACKUP"
            set source 192.168.1.1
            set gateway 10.254.1.1
            set cost 1
        next
    end
end

config system sdwan
    config health-check
        edit "datacenter1"
            set server "10.200.1.1"
            set members 0
            config sla
                edit 1
                    set latency-threshold 50
                    set jitter-threshold 50
                    set packetloss-threshold 1
                next
            end
        next
    end
end

config system sdwan
    config service
        edit 1
            set name "FAILOVER-STRATEGY"
            set mode sla
            set dst "all"
            set src "all"
            config sla
                edit "datacenter1"
                    set id 1
                next
            end
            set priority-members 1 2
        next
    end
end

5. POLICY
config firewall policy
    edit 1
        set name "Allow All"
        set srcintf "any"
        set dstintf "any"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
    next
end


Validation
The following commands can be used to validate the connections on the datacenter and branches.

Datacenter
Routing table:
# get router info routing-table all
VPN establishment:
# diagnose vpn ike gateway list
Branch
SD-WAN validation:
# diagnose sys sdwan member
# diagnose sys sdwan service
# diagnose sys sdwan health-check
Routing table:
# get router info routing-table all
# get router info route-map-address
# get router info bgp route-map <route-map-name>
VPN establishment:
# diagnose vpn ike gateway list