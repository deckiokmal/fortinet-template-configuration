#1 VPN Site to Site - MikroTik
config firewall address
    edit "local_vascomm"
        set allow-routing enable
        set subnet 192.168.188.0 255.255.255.0
    next
    edit "remote_vascomm"
        set allow-routing enable
        set subnet 17.3.3.0 255.255.255.0
    next
end

config firewall addrgrp
    edit "tunnel_vascomm_local"
        set member "local_vascomm"
        set allow-routing enable
    next
    edit "tunnel_vascomm_remote"
        set member "remote_vascomm"
        set allow-routing enable
    next
end

config vpn ipsec phase1-interface
    edit "tunnel_vascomm"
        set interface "wan"
        set ike-version 2
        set local-gw 202.152.33.66
        set peertype any
        set net-device disable
        set proposal 3des-sha1
        set dhgrp 2
        set remote-gw 108.137.160.251
        set psksecret Vascom@2023#
    next
end

config vpn ipsec phase2-interface
    edit "tunnel_vascomm"
        set phase1name "tunnel_vascomm"
        set proposal 3des-sha1
        set dhgrp 2
        set auto-negotiate enable
        set src-addr-type name
        set dst-addr-type name
        set src-name "tunnel_vascomm_local"
        set dst-name "tunnel_vascomm_remote"
    next
end

config firewall policy
    edit 20
        set name "vascomm-to-lan"
        set srcintf "lan"
        set dstintf "tunnel_vascomm"
        set srcaddr "tunnel_vascomm_local"
        set dstaddr "tunnel_vascomm_remote"
        set action accept
        set schedule "always"
        set service "ALL"
    next
    edit 21
        set name "lan-to-vascomm"
        set srcintf "tunnel_vascomm"
        set dstintf "lan"
        set srcaddr "tunnel_vascomm_remote"
        set dstaddr "tunnel_vascomm_local"
        set action accept
        set schedule "always"
        set service "ALL"
    next
end

config router static
    edit 15
        set device "tunnel_vascomm"
        set dstaddr "tunnel_vascomm_remote"
    next
    edit 16
        set distance 254
        set blackhole enable
        set dstaddr "tunnel_vascomm_remote"
    next
end
