1. Underlay Network
config system virtual-switch
    edit "lan"
        config port
            delete "lan3"
            next
        end
    next
end

config system interface
    edit "wan"
        set vdom "root"
        set ip 36.95.70.77 255.255.255.0
        set allowaccess ping https ssh fgfm
        set type physical
        set alias "WAN Telkom"
        set monitor-bandwidth enable
        set role wan
        set snmp-index 1
    next
    edit "lan3"
        set vdom "root"
        set ip 1.2.61.230 255.255.255.252
        set allowaccess ping https ssh snmp telnet
        set type physical
        set device-identification enable
        set lldp-reception enable
        set lldp-transmission enable
        set monitor-bandwidth enable
        set role wan
        set snmp-index 6
    next
    edit "lan"
        set vdom "root"
        set ip 192.168.133.1 255.255.255.224
        set allowaccess ping https ssh snmp telnet fgfm
        set type hard-switch
        set stp enable
        set role lan
        set snmp-index 4
        set secondary-IP enable
        config secondaryip
            edit 1
                set ip 1.5.194.4 255.255.255.255
                set allowaccess ping https ssh snmp telnet fgfm
            next
        end
    next
end

2. Overlay Network
config vpn ipsec phase1-interface
    edit "HUB-AN"
        set interface "wan"
        set ike-version 2
        set peertype any
        set net-device enable
        set mode-cfg enable
        set proposal aes192-sha256
        set add-route disable
        set dpd on-idle
        set dhgrp 5
        set idle-timeout enable
        set auto-discovery-receiver enable
        set network-overlay enable
        set network-id 1
        set remote-gw 61.8.76.226
        set psksecret ENC PuT3stY0a06PErD+yCRpASX/jGPo/uMUgNhK3puhKEfbb9IteEaYLI94uY7VGMCByLKUokszcrrX/yDgzSlPnjAiYQ2dlVbh54eot13y67NLL2+E+B/lRHlumjcagvDvn8vsLoHG67KBMfIdyGc0VE541JOhmSFDUqdXBIcihO3/Ht9vOrgtxD1qzUfPJ1pdSneoYQ==
        set dpd-retryinterval 21
    next
    edit "HUB-LA"
        set interface "lan3"
        set ike-version 2
        set peertype any
        set net-device enable
        set mode-cfg enable
        set proposal aes192-sha256
        set add-route disable
        set dpd on-idle
        set dhgrp 5
        set idle-timeout enable
        set auto-discovery-receiver enable
        set network-overlay enable
        set network-id 2
        set remote-gw 1.11.4.54
        set psksecret ENC A6y7uFFWTSL1ypRdvRheqG/CNSHP1zklopRJ98F/riRJ8FPia0CHPJ9FI9IHuBqybqqJL32VLLkmqD0EWk04SSj7TDZfMenbgGx14wJNv1c1xMwv8HVhjc0hmWUuDUGFMlDzDBKTykpZINdOToTM0NtluDm4rUDi+Ojex4XtqdEYpbjg68dqD6SuN2/76Fgevqdddg==
        set dpd-retryinterval 21
    next
    edit "HUB-CGS"
        set interface "wan"
        set ike-version 2
        set peertype any
        set net-device enable
        set mode-cfg enable
        set proposal aes192-sha256
        set add-route disable
        set dpd on-idle
        set dhgrp 5
        set idle-timeout enable
        set auto-discovery-receiver enable
        set network-overlay enable
        set network-id 3
        set remote-gw 192.145.228.9
        set psksecret ENC HJAk3jKVlGhbMjXEeztpgrul7sXwEfwc6jL9mdSTn+/AIgKjvfTsk1dSztSN5rVOm1b0IgDUU1i/KHwESu1hb5HPjUjenEOR58zdHCZAw9c7YfZ7WuewttwyCW1CDo3Sm4ovTcAtmi8n7F/QDclX/CKs3+nsSwboPDMgR3YtdB6nSsyHsoKETP7OcjI/sgc4/SpBlw==
        set dpd-retryinterval 21
    next
end

3. Routing
config router aspath-list
    edit "LOCAL-ROUTES"
        config rule
            edit 1
                set action permit
                set regexp "^$"
            next
        end
    next
end
config router community-list
    edit "65121:1"
        config rule
            edit 1
                set action permit
                set match "65121:1"
            next
        end
    next
end
config router route-map
    edit "OUT-TO-HUB"
        config rule
            edit 1
                set match-as-path "LOCAL-ROUTES"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
            next
        end
    next
    edit "OUT-TO-HUB-SLA-OK"
        config rule
            edit 1
                set match-as-path "LOCAL-ROUTES"
                set set-community "65121:123"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
            next
        end
    next
    edit "IN-FROM-HUB"
        config rule
            edit 1
                set match-community "65121:1"
                unset set-ip-nexthop
                unset set-ip6-nexthop
                unset set-ip6-nexthop-local
                unset set-originator-id
                set set-route-tag 651211
            next
        end
    next
end
config router bgp
    set as 65121
    set router-id 192.168.133.1
    set ibgp-multipath enable
    config neighbor
        edit "169.254.234.254"
            set remote-as 65121
            set route-map-in "IN-FROM-HUB"
            set route-map-out "OUT-TO-HUB"
            set route-map-out-preferable "OUT-TO-HUB-SLA-OK"
            set connect-timer 1
        next
        edit "169.254.235.254"
            set remote-as 65121
            set route-map-in "IN-FROM-HUB"
            set route-map-out "OUT-TO-HUB"
            set route-map-out-preferable "OUT-TO-HUB-SLA-OK"
            set connect-timer 1
        next
        edit "169.254.236.254"
            set remote-as 65121
            set route-map-in "IN-FROM-HUB"
            set route-map-out "OUT-TO-HUB"
            set route-map-out-preferable "OUT-TO-HUB-SLA-OK"
            set connect-timer 1
        next
    end
    config network
        edit 1
            set prefix 192.168.133.0 255.255.255.224
        next
        edit 2
            set prefix 1.5.194.4 255.255.255.255
        next
    end
    config redistribute "connected"
    end
    config redistribute "rip"
    end
    config redistribute "ospf"
    end
    config redistribute "static"
    end
    config redistribute "isis"
    end
    config redistribute6 "connected"
    end
    config redistribute6 "rip"
    end
    config redistribute6 "ospf"
    end
    config redistribute6 "static"
    end
    config redistribute6 "isis"
    end
end

4. SDWAN
config system sdwan
    set status enable
    set load-balance-mode source-dest-ip-based
    config zone
        edit "virtual-wan-link"
        next
        edit "HUB"
        next
    end
    config members
        edit 1
            set interface "HUB-AN"
            set zone "HUB"
            set gateway 169.254.234.254
            set source 192.168.133.1
        next
        edit 2
            set interface "HUB-LA"
            set zone "HUB"
            set gateway 169.254.235.254
            set source 192.168.133.1
        next
        edit 3
            set interface "HUB-CGS"
            set zone "HUB"
            set gateway 169.254.236.254
            set source 192.168.133.1
        next
    end
    config health-check
        edit "SLA_TO_HUB"
            set server "1.11.4.45"
            set interval 1000
            set probe-timeout 2000
            set update-static-route disable
            set members 1 3 2
            config sla
                edit 1
                    set latency-threshold 100
                    set jitter-threshold 50
                    set packetloss-threshold 1
                next
            end
        next
        edit "SERVER"
            set server "192.168.1.33"
            set members 3 2
        next
    end
    config neighbor
        edit "169.254.234.254"
            set member 1
            set health-check "SLA_TO_HUB"
            set sla-id 1
        next
        edit "169.254.235.254"
            set member 2
            set health-check "SLA_TO_HUB"
            set sla-id 1
        next
        edit "169.254.236.254"
            set member 3
            set health-check "SLA_TO_HUB"
            set sla-id 1
        next
    end
    config service
        edit 1
            set name "RULES-TO-HUB"
            set mode load-balance
            set route-tag 651211
            set src "all"
            config sla
                edit "SLA_TO_HUB"
                    set id 1
                next
            end
            set priority-members 3 2 1
        next
    end
end

5. Firewall Policy
config firewall policy
    edit 1
        set name "SPOKE-TO-HUB"
        set uuid 46f36498-1e2f-51ed-05b3-3f12d82ef4f4
        set srcintf "lan"
        set dstintf "HUB"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
    next
    edit 2
        set name "HUB-TO-SPOKE"
        set uuid 4a06d566-1e2f-51ed-ad50-b01fe1ea4766
        set srcintf "HUB"
        set dstintf "lan"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
    next
end
