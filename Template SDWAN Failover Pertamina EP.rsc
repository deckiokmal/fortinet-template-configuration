config system interface
    edit "MAIN"
        set vdom "root"
        set ip 192.168.111.31 255.255.255.0
        set allowaccess ping https ssh
        set device-identification enable
        set role lan
        #set snmp-index 13
        set interface "wan1"
        set vlanid 111
    next
end

config system interface
    edit "BACKUP"
        set vdom "root"
        set ip 192.168.222.31 255.255.255.0
        set allowaccess ping https ssh
        set device-identification enable
        set role lan
        #set snmp-index 14
        set interface "wan1"
        set vlanid 222
    next
end

config system sdwan
    set status enable
    config zone
        edit "virtual-wan-link"
        next
        edit "FAILOVER-ZONE"
        next
    end
    config members
        edit 3
            set interface "MAIN"
            set zone "FAILOVER-ZONE"
            set gateway 192.168.111.254
            set source 10.203.48.43
        next
        edit 4
            set interface "BACKUP"
            set zone "FAILOVER-ZONE"
            set gateway 192.168.222.254
            set source 10.203.48.43
            set cost 1
        next
    end
    config health-check
        edit "Default_DNS"
            set system-dns enable
            set interval 1000
            set probe-timeout 1000
            set recoverytime 10
            config sla
                edit 1
                    set latency-threshold 250
                    set jitter-threshold 50
                    set packetloss-threshold 5
                next
            end
        next
        edit "PEP"
            set server "10.203.0.2"
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
    set router-id 10.203.48.43
    set ibgp-multipath enable
    config neighbor
        edit "192.168.111.254"
            set link-down-failover enable
            set soft-reconfiguration enable
            set description "MAIN"
            set remote-as 65000
            set connect-timer 1
        next
        edit "192.168.222.254"
            set link-down-failover enable
            set soft-reconfiguration enable
            set description "BACKUP"
            set remote-as 65000
            set connect-timer 1
        next
    end

config firewall policy
    edit 1
        set name "TRAFFIC-OUT"
        #set uuid 5a2703be-820f-51ed-528b-7e60823b64f9
        set srcintf "lan" "LAN-OTHER" "Loopback0"
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
        #set uuid 2e1a58b4-82f7-51ed-4335-73ce26a78180
        set srcintf "FAILOVER-ZONE"
        set dstintf "lan" "LAN-OTHER" "Loopback0"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 3
        set name "LAN-TO-LAN"
        #set uuid 1b845e0a-addd-51ed-6efd-c29194ddab55
        set srcintf "lan" "LAN-OTHER"
        set dstintf "lan" "LAN-OTHER"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
    next
end