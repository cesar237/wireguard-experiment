import fabric as fab
import os

username = 'root'
machines = ['client', 'server', 'target']
nodes = {}
nodes['server'] = os.environ['server']
nodes['client'] = os.environ['clients']
nodes['target'] = os.environ['targets']

pool = fab.Group(nodes.items())

connections = {}
for machine in machines:
    connections[machine] = fab.Connection(host=nodes[machine], user=username)

    
# Setup the test environment
# 1. Compile and Wireguard on server
#   Variables: 
#       - wireguard_variant [kernel-6.1 or wireguard-batch]
# 2. Reload Wireguard interface
# 3. Setup network configuration
#       - sysctl net.ipv4.ip_forward=1 # on server
#       - ip route add $target_ip via $server ip # on clients


