1. UNDERLAY

2. OVERLAY
config vpn ipsec phase1-interface
    edit "T-MAIN"
        set type dynamic
        set interface "VPN-BPD-JAMBI"
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
        set interface "port2"
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
        set ip 10.254.0.1 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.0.254 255.255.255.0
        set interface "VPN-BPD-JAMBI"
    next
    edit "T-BACKUP"
        set ip 10.254.1.1 255.255.255.255
        set allowaccess ping
        set type tunnel
        set remote-ip 10.254.1.254 255.255.255.0
        set interface "port2"
    next
end

config system interface
    edit "loopback_0"
        set vdom BPD-JAMBI
        set ip 10.255.255.1 255.255.255.255
        set allowaccess ping
        set type loopback
    next
end

config router bgp
    set as 64888
    set router-id 1.11.8.38
    set ibgp-multipath enable
    set graceful-restart enable
    config neighbor-group
        edit "T-MAIN-peer"
            set soft-reconfiguration enable
            set link-down-failover enable
            set next-hop-self enable
            set remote-as 64888
            set route-reflector-client enable
        next
        edit "T-BACKUP-peer"
            set soft-reconfiguration enable
            set link-down-failover enable
            set next-hop-self enable
            set remote-as 64888
            set route-reflector-client enable
        next
    end
    config neighbor-range
        edit 1
            set prefix 10.254.0.0 255.255.255.0
            set neighbor-group "T-MAIN-peer"
        next
        edit 2
            set prefix 10.254.1.0 255.255.255.0
            set neighbor-group "T-BACKUP-peer"
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
