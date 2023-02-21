1. UNDERLAY

2. OVERLAY
config vpn ipsec phase1-interface
    edit "T-MAIN"
        set type dynamic
        set interface "port2"
        set peertype any
        set exchange-interface-ip enable
        set proposal aes256-sha256
        set add-route disable
        set dhgrp 5
        set net-device enable
        set psksecret L1nt4s4rt@
    next
    edit "T-BACKUP"
        set type dynamic
        set interface "port3"
        set peertype any
        set exchange-interface-ip enable
        set proposal aes256-sha256
        set add-route disable
        set dhgrp 5
        set net-device enable
        set psksecret L1nt4s4rt@
    next
end

config vpn ipsec phase2-interface
    edit "T-MAIN_p2"
        set phase1name "T-MAIN"
        set proposal aes256-sha256
        set pfs disable
        set replay disable
    next
    edit "T-BACKUP_p2"
        set phase1name "T-BACKUP"
        set proposal aes256-sha256
        set pfs disable
        set replay disable
    next
end

3. ROUTING
config system interface
    edit "T-MAIN"
        set vdom "root"
        set ip 10.254.0.1 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.0.254 255.255.255.0
        set interface "port2"
    next
    edit "T-BACKUP"
        set vdom "root"
        set ip 10.254.1.1 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.1.254 255.255.255.0
        set interface "port3"
    next
end

config system interface
    edit "loopback_0"
        set vdom "root"
        set ip 10.255.255.1 255.255.255.255
        set allowaccess ping
        set type loopback
    next
end

config router bgp
    set as 65500
    set router-id 10.10.0.1
    set ebgp-multipath enable
    set graceful-restart enable
    config neighbor-group
        edit "branch-peers-1"
            set soft-reconfiguration enable
            set remote-as 65501
            set route-reflector-client enable
        next
        edit "branch-peers-2"
            set soft-reconfiguration enable
            set remote-as 65501
            set route-reflector-client enable
        next
    end
    config neighbor-range
        edit 1
            set prefix 10.254.0.0 255.255.255.0
            set neighbor-group "branch-peers-1"
        next
        edit 2
            set prefix 10.254.1.0 255.255.255.0
            set neighbor-group "branch-peers-2"
        next
    end
    config network
        edit 1
            set prefix 10.200.1.0 255.255.255.0
        next
        edit 2
            set prefix 10.200.0.0 255.255.255.0
        next
        edit 3
            set prefix 10.200.3.0 255.255.255.0
        next
    end
end

4. POLICY
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

config router static
    edit 6
        set dst 10.0.0.0/14
        set distance 254
        set blackhole enable
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