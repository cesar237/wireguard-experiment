#! /usr/bin/python3
import argparse
import json
import os

template = """
[Interface]
Address = {}
PostUp =  iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o {{ iface }} -j MASQUERADE; ip rule add from {} lookup {}
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o {{ iface }}  -j MASQUERADE; ip rule add from {} lookup {}
ListenPort = {}
PrivateKey = {}
Table = {}

[Peer]
PublicKey = {}
AllowedIPs = 0.0.0.0/0
Endpoint = {}
"""


parser = argparse.ArgumentParser()
parser.add_argument("-k", "--keypairs", required=True, help="The file that holds the client keypairs")
parser.add_argument("-s", "--server-keypairs", required=True, help="The file that holds the server keypairs")
parser.add_argument("-n", "--nfiles", required=True, type=int, help="The number of conf files to generate")
parser.add_argument("-d", "--server-ip", required=True, help="The physical IP address of the Wireguard server")
parser.add_argument("-m", "--is-personal", action='store_true', default=False)
# parser.add_argument("-b", "--client-batch", required=True, help="The number of Wireguard clients per batch")
parser.add_argument("-i", "--index", required=True, type=int, help="The index from which the conf files are generated")
parser.add_argument("-o", "--output-dir", default=".", help="The directory where the generated conf files are stored")
args = parser.parse_args()

if __name__ == "__main__":
    with open(args.keypairs) as keypairs, open(args.server_keypairs) as s_keypairs:
        keypairs = json.load(keypairs)
        s_keypairs = json.load(s_keypairs)

    os.makedirs(args.output_dir, exist_ok=True)
    client_idx = args.index

    for i in range(args.nfiles):
        global_index = args.nfiles*(args.index - 1) + i
        if args.is_personal:
            X, Y = global_index // 8, (global_index % 8) << 5
            wg_server_address = f"192.168.{X}.{Y+1}"
        else:
            X, Y = client_idx, i
            wg_server_address = f"192.168.0.1"
        c_suffix = f"192.168.{X}.{Y+2}"
        private_ip_addr = f"192.168.{X}.{Y+2}"
        table_index = i+1
        # global_index = args.nfiles*(args.index - 1) + i
        client_port = 51820 + i
        private_key = keypairs[str(global_index+1)]["Private Key"]
        key_idx = str(global_index+1) if args.is_personal else "1"
        server_key = s_keypairs[key_idx]["Public Key"]
        server_port = global_index if args.is_personal else 0
        server_ip_addr = f"{args.server_ip}:{51820+server_port}"

        res = template.format(
            private_ip_addr,
            private_ip_addr,
            table_index,
            private_ip_addr,
            table_index,
            client_port,
            private_key,
            table_index,
            server_key,
            server_ip_addr,
        )
        with open(f"{args.output_dir}/wg-{i+1}.conf", "w") as f:
            f.write(res)
