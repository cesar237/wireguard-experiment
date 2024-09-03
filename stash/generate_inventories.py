#! /usr/bin/python3

import argparse
import os


TRHOUGHPUT_NFLOW_SET = "2 10 30 50 80 100"
LATENCY_NFLOW_SET = "100"

UDP_PACKET_SIZE = "1500"
TCP_PACKET_SIZE = "128k"

THROUGHPUT_UNIT_TIME = 70
LATENCY_UNIT_TIME = 120

site = "nancy"

VARIANTS = [
    "wireguard-lkm",
    "wireguard-go",
    "wireguard-rs",
    "tailscale",
    "boring-tun"
]

CONFIG = [
    'irqbalance',
    'RSS',
]

irqbalance = False
rss = False
udp_traffic = False
hyperthreaded = False


host_template = """        {node}:
          ansible_host: {node}.{site}.grid5000.fr
"""

inventory_template = """
all:
  vars:
    keypairs: "{{{{ lookup('file', 'keypairs.json') | from_json }}}}"
    index: "{{{{ lookup('file', 'index.json') | from_json }}}}"
    target_index: "{{{{ lookup('file', 'target_index.json') | from_json }}}}"
    server_keypairs: "{{{{ lookup('file', 'server_keypairs.json') | from_json }}}}"
    server_address: "{{{{ hostvars[groups['server'][0]]['ansible_facts']['default_ipv4']['address'] }}}}"
    # target_address: "{{{{ hostvars[groups['target'][0]]['ansible_facts']['default_ipv4']['address'] }}}}"
    username_server: root
    username_client: root
    username_target: root
    username: root

    n_clients: 1000
    # Choose testname between TCP_STREAM, TCP_MAERTS (Deprecated)
    netperf_testname: "TCP_STREAM"
    latency_test : {latency_test} # TCP_RR or UDP_RR for UDP
    latency_req_res_size: {latency_sizespec} # default "1500,1"
    batch: 100
    irqbalanced: {irqbalanced}
    test_latency: {latency}
    all_on_core_0: {on_core_0}
    deactivate_rss: {deactivate_rss}

    iperf_udp: {udp}
    queue_length: 1024
    bandwidth: 30M
    packet_size: {packet_size} # MAX = 1048576 and 1460 for UDP

    bandwidth_varying: False
    bandwidth_list: 1G 3G 6G 9G 12G 15G 20G 22G 25G
    
    pinned_napi: False
    hyperthreaded: False # {hyperthreaded}

    wg_userspace: {wg_userspace}
    wireguard_go_tailscale: {tailscale}
    boringtun: {boringTUN}
    wireguard_rs: {wireguard_rs}
    
    test_iperf3: {test_iperf3}
    test_netperf: {test_netperf}
    test_hey: {test_hey}
    test_deathstar: {test_deathstar}
    
    # Configs for Web test (Hey)
    webserver: nginx # possible values nginx and apache2
    index_file_size: 100K # Possible values are 1M, 100K, 10K and 1K
    webserver_test_length: 50s # put time here, 10s or 1m for minutes
    webserver_nworker: 200
    index_file_distributed : True # If true, will configure n_1K*n_nodes that will fetch 1K, n_10K*n_nodes that will fetch 10k, etc.
    n_1K: 25
    n_10K: 25
    n_100K: 25
    n_1M: 25 # sum of n_1K, n_10K n_100K and n_1M must be batch = 100 by default

    # Choose sched policy: -o for default, -b for batch, -f for fifo and -r for round robin
    sched_policy: "-b"
    # Choose sched priority: 0 for default and batch, 1 for fifo and round robin
    sched_priority: 0
    apply_sched_policy: false
    test_irqbalance: false
    download: {download}
    bidirectional: {bidir}
    is_personal: False
    wg_activated: True
    limited_bandwidth: False
    limit_bandwidth: "30mbit"
    ncore_set: "36"
    #ncore_set: "7,ffffffff 0,0fffffff 0,0000ffff 0,00000fff 0,000000ff 0,0000000f 0,00000001"
    nflow_set: "{nflow_set}"
    unit_time_s: {unit_time}
    script_path: "/tmp/scripts"
    results_path: "/tmp/results"
    ftrace_path: "/sys/kernel/debug/tracing"
  children:
    server:
      hosts:
{server}
    targets:
      hosts:
{targets}
    clients:
      hosts:
{clients}
    wg:
      children:
        server:
        clients:
"""

parser = argparse.ArgumentParser()
parser.add_argument('-v', '--variants', nargs='+', required=False, default=VARIANTS, help="List of variants to generate traffic")
parser.add_argument('-i', '--irqbalance', action='store_true', default=False, help="Activate IRQBalance")
parser.add_argument('-r', '--rss', action='store_true', default=False, help="Activate RSS")
parser.add_argument('-u', '--udp', action='store_true', default=False, help="Use UDP traffic instead of TCP")
parser.add_argument('-n', '--hyperthreaded', action='store_true', default=False, help="Activate/Deactivate Hyperthreading")
parser.add_argument('-l', '--latency', action='store_true', default=False, help="Perform Latency test")
parser.add_argument('-t', '--latency-test', required=False, default="TCP_RR", help="TCP_RR or UDP_RR")
parser.add_argument('-s', '--site', required=False, default="nancy", help="Grid5000 site")
parser.add_argument('-d', '--download', action='store_true', default=False, help="Download type (TARGET => CLIENT)")
parser.add_argument('-b', '--bidir', action='store_true', default=False, help="Bidirection type (CLIENT <=> TARGET)")
parser.add_argument('-w', '--web', action='store_true', default=False, help="Web type")
parser.add_argument('-x', '--deathstar', action='store_true', default=False, help="Deathstar")
parser.add_argument('-o', '--output', required=False, default="inventory-nop", help="Output directory")
args = parser.parse_args()


def generate_inventory(
    variant, 
    site='nancy',
    latency=False, 
    udp=False,
    irqbalanced=False, 
    on_core_0=True, 
    bidir=False,
    latency_sizespec="1500,1",
    download=False,
    latency_test='TCP_RR',
    deactivate_rss=True, 
    hyperthreaded=True,
    test_iperf3=True,
    test_netperf=False,
    test_hey=False,
    test_deathstar=False,
    server="gros-1",
    targets=["gros-2"],
    clients=["gros-3"]
    ):
    
    packet_size=TCP_PACKET_SIZE
    wg_userspace=False
    tailscale=False
    boringTUN=False
    wireguard_rs=False
    nflow_set=TRHOUGHPUT_NFLOW_SET
    unit_time=THROUGHPUT_UNIT_TIME
    
    if latency:
        nflow_set = LATENCY_NFLOW_SET
        udp = False
        unit_time = LATENCY_UNIT_TIME
    
    if udp:
        packet_size = UDP_PACKET_SIZE
    
    if variant == 'wireguard-go':
        wg_userspace = True
    
    if variant == 'wireguard-rs':
        wg_userspace = True
        wireguard_rs = True
    
    if variant == 'tailscale':
        wg_userspace = True
        tailscale = True
    
    if variant == 'boring-tun':
        wg_userspace = True
        boringTUN = True
        
    if variant == 'wireguard-lkm':
        wg_userspace = False
        boringTUN = False
        
    server = host_template.format(node=server, site=site)
    targets = "".join([host_template.format(node=n, site=site) for n in targets])
    clients = "".join([host_template.format(node=n, site=site) for n in clients])
    
    return inventory_template.format(
        latency=latency, 
        udp=udp,
        irqbalanced=irqbalanced, 
        on_core_0=on_core_0, 
        deactivate_rss=deactivate_rss, 
        packet_size=packet_size,
        hyperthreaded=hyperthreaded,
        test_iperf3=True,
        test_netperf=False,
        test_hey=False,
        test_deathstar=False,
        wg_userspace=wg_userspace,
        tailscale=tailscale,
        download=download,
        latency_test=latency_test,
        latency_sizespec=latency_sizespec,
        bidir=bidir,
        boringTUN=boringTUN,
        wireguard_rs=wireguard_rs,
        nflow_set=nflow_set,
        unit_time=unit_time,
        server=server,
        targets=targets,
        clients=clients
    )

if __name__ == "__main__":
    server = ""
    clients = []
    targets = []
    
    # Read SERVER file to get the server node
    with open('SERVER', 'r') as f:
        server = f.readlines()[0].strip()

    # Read TARGETS file to get the targets node
    with open('TARGETS', 'r') as f:
        targets = [s.strip() for s in f.readlines()]
        
    # Read CLIENTS file to get the targets node
    with open('CLIENTS', 'r') as f:
        clients = [s.strip() for s in f.readlines()]
    
    # print(args.variants)
    
    irqbalanced = False
    on_core_0=True 
    deactivate_rss = True
    download = args.download
    bidir = args.bidir
    latency_sizespec = "1500,1"
    test_iperf3=True
    test_netperf=False
    test_hey=False
    test_deathstar=False
    
    for variant in args.variants:        
        if args.irqbalance:
            irqbalanced = True
            on_core_0 = False
        if args.rss:
            on_core_0 = False
            deactivate_rss = False
        if download:
            latency_sizespec = "1,1500"
        if bidir:
            latency_sizespec = "1500,1500"
        
             
        # args.web args.deathstar
        if args.web:
            test_iperf3=False
            test_netperf=False
            test_hey=True
            test_deathstar=False
        if args.deathstar:
            test_iperf3=False
            test_netperf=False
            test_hey=False
            test_deathstar=True
        if args.latency:
            test_iperf3=False
            test_netperf=True
            test_hey=False
            test_deathstar=False
        
        inv = generate_inventory(
            variant=variant,
            latency=args.latency, 
            udp=args.udp,
            irqbalanced=irqbalanced,
            latency_test=args.latency_test, 
            download=download,
            bidir=bidir,
            test_iperf3=test_iperf3,
            test_netperf=test_netperf,
            test_hey=test_hey,
            test_deathstar=test_deathstar,
            latency_sizespec=latency_sizespec,
            on_core_0=on_core_0, 
            deactivate_rss=deactivate_rss, 
            hyperthreaded=args.hyperthreaded,
            server=server,
            targets=targets,
            clients=clients
        )   
        
        if args.output is not None:
            
            directory = "inventory"
            if args.irqbalance and args.rss:
                directory += '-irqbalance-rss'
            if not args.irqbalance and args.rss:
                directory += '-rss'
            if not args.irqbalance and not args.rss:
                directory += '-nop'
            if args.irqbalance and not args.rss:
                directory += '-irqbalance'
            
            os.makedirs(directory, exist_ok=True)
            
            prefix = 'inventory'
            name = []
            
            if args.latency:  
                if args.latency_test == 'TCP_RR':
                    name.append('latency-tcp')
                elif args.latency_test == 'UDP_RR':
                    name.append('latency-udp')
            else:
                if args.udp:
                    name.append('udp')
                else:
                    name.append('tcp')

            if args.download:
                name.append('DOWNLOAD')
            elif args.bidir:
                name.append('BIDIR')
            elif args.web:
                name.append('WEBHEY')
            elif args.deathstar:
                name.append("DEATHSTAR")
            else:
                name.append('UPLOAD')
            
            name.append(f'{variant}')
            
            test_name = '-'.join(name)
            name = f'{prefix}-{test_name}.yaml'
            
            with open(f'{directory}/{name}', 'w') as f:
                f.write(inv)
            
            with open('test_list', 'a') as f:
                f.write(f'{test_name}\n')
