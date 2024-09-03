#! /usr/bin/python3
import argparse
import json
import os

template = """
[Interface]
Address = {}
PostUp =  iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eno1  -j MASQUERADE
ListenPort = {}
PrivateKey = {}
"""

template_usr_space = """
[Interface]
#Address = {}
#PostUp =  iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
#PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eno1  -j MASQUERADE
ListenPort = {}
PrivateKey = {}
"""

template_clients = """
[Peer]
PublicKey = {}
AllowedIPs = {}
"""


parser = argparse.ArgumentParser()
parser.add_argument("-k", "--keypairs", required=True, help="The file that holds the client keypairs")
parser.add_argument("-s", "--server-keypairs", required=True, help="The file that holds the server keypairs")
parser.add_argument("-n", "--n-clients", required=True, type=int, help="The number of conf files to generate")
parser.add_argument("-m", "--is-personal", action='store_true', default=False)
parser.add_argument("-b", "--batch", required=True, type=int, help="The number of clients per batch")
parser.add_argument("-u", "--user-space", action='store_true', default=False, help="The number of clients per batch")
parser.add_argument("-o", "--output-dir", default=".", help="The directory where the generated conf files are stored")
args = parser.parse_args()

if __name__ == "__main__":
    with open(args.keypairs) as keypairs, open(args.server_keypairs) as s_keypairs:
        keypairs = json.load(keypairs)
        s_keypairs = json.load(s_keypairs)

    os.makedirs(args.output_dir, exist_ok=True)

    if args.user_space:
        template = template_usr_space

    if args.is_personal:
        for i in range(args.n_clients):
            idx = i + 1
            X, Y= i // 8, (i % 8) << 5
            s_suffix = f"192.168.{X}.{Y+1}"
            c_suffix = f"0.0.0.0/0"
            res = template.format(s_suffix, 51820+i, s_keypairs[str(idx)]["Private Key"])
            res += template_clients.format(keypairs[str(idx)]["Public Key"], c_suffix)
            with open(f"{args.output_dir}/wg-{idx}.conf", "w") as f:
                f.write(res)
    else:
        private_address = "192.168.0.1"
        port = 51820
        private_key = s_keypairs["1"]["Private Key"]
        res = template.format(
            private_address,
            port,
            private_key
        )
        for i in range(args.n_clients):
            idx = i + 1
            X, Y= i//args.batch + 1, i%args.batch+2
            client_address = f"192.168.{X}.{Y}"
            pubkey = keypairs[str(idx)]["Public Key"]
            res += template_clients.format(
                pubkey,
                client_address
            )
        with open(f"{args.output_dir}/wg.conf", "w") as f:
            f.write(res)
