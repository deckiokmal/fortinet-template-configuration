#Routing tshoot
diag sniffer packet port1 'none' 4 0

#debug BGP
diag ip router bgp level info
diag ip router bgp all enable
diag ip router bgp show
diag debug enable

diag debug reset
diag debug disable

#debug flow
diag debug enable
diag debug flow filter addr 8.8.8.8
diag diag flow show function-name enable
diag debug flow trace start 1000

#stop debug
diag debug reset
diag debug disable

