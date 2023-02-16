cpelintasartassa
L1nt4s4rt@_SSA!

config system interface
    edit "MAIN"
        set vdom "root"
        set ip 192.168.111.38 255.255.255.0
        set allowaccess ping ssh https
        set interface "wan1"
        set vlanid 111
    next
    edit "BACKUP"
        set vdom "root"
        set ip 192.168.222.38 255.255.255.0
        set allowaccess ping ssh https
        set interface "wan1"
        set vlanid 222
    next
    edit "wan1"
        set vdom "root"
        set ip 0.0.0.0/0
        set allowaccess ping https ssh snmp
        set type physical
        set lldp-reception enable
        set role wan
    next
end

config system sdwan
    set status enable
    config zone
        edit "FAILOVER-ZONE"
        next
    end
    config members
        edit 3
            set interface "MAIN"
            set gateway 192.168.111.254
            set source 10.203.48.44
            set zone "FAILOVER-ZONE"
        next
        edit 4
            set interface "BACKUP"
            set gateway 192.168.222.254
            set source 10.203.48.44
            set cost 1
            set zone "FAILOVER-ZONE"
        next
    end
    config health-check
        edit "PEP"
            set server "10.203.0.1"
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
    config service
        edit 2
            set name "FAILOVER-STRATEGY"
            set mode sla
            set dst "all"
            set src "all"
            config sla
                edit "PEP"
                    set id 1
                next
            end
            set priority-members 3 4
        next
    end
end

config router bgp
    set as 65000
    set router-id 10.203.48.44
    set ibgp-multipath enable
    config neighbor
        edit "192.168.111.254"
            set description "MAIN"
            set link-down-failover enable
            set soft-reconfiguration enable
            set remote-as 65000
            set connect-timer 1
        next
        edit "192.168.222.254"
            set description "BACKUP"
            set link-down-failover enable
            set soft-reconfiguration enable
            set remote-as 65000
            set connect-timer 1
        next
        delete 1.11.16.254
    end
end

config router static
    edit 1
        set distance 1
        set sdwan-zone "FAILOVER-ZONE"
        set sdwan enable
    next
end

config firewall policy
    edit 1
        set name "TRAFFIC-OUT"
        set srcintf "Loopback0" "lan" "LAN-OTHER"
        set dstintf "FAILOVER-ZONE"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 2
        set name "TRAFFIC-IN"
        set srcintf "FAILOVER-ZONE"
        set dstintf "Loopback0" "lan" "LAN-OTHER"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 3
        set name "LAN-TO-LAN"
        set srcintf "lan" "LAN-OTHER"
        set dstintf "lan" "LAN-OTHER"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
    next
end