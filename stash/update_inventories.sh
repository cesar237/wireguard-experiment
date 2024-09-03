
# ./generate_inventories.py
# ./generate_inventories.py -u
# ./generate_inventories.py -l

# ./generate_inventories.py -i
# ./generate_inventories.py -i -u
# ./generate_inventories.py -i -l

# ./generate_inventories.py -r
# ./generate_inventories.py -r -u
# ./generate_inventories.py -r -l

# ./generate_inventories.py -ir
# ./generate_inventories.py -ir -u
# ./generate_inventories.py -ir -l

# ./generate_inventories.py -ir -v wireguard-lkm
# ./generate_inventories.py -ir -u -v wireguard-lkm
# ./generate_inventories.py -ir -l -t TCP_RR -v wireguard-lkm
# ./generate_inventories.py -ir -l -t UDP_RR -v wireguard-lkm


# ./generate_inventories.py -ir -d -v wireguard-lkm
# ./generate_inventories.py -ir -u -d -v wireguard-lkm
# ./generate_inventories.py -ir -l -t TCP_RR -d -v wireguard-lkm
# ./generate_inventories.py -ir -l -t UDP_RR -d -v wireguard-lkm


# ./generate_inventories.py -ir -b -v wireguard-lkm
# ./generate_inventories.py -ir -u -b -v wireguard-lkm
./generate_inventories.py -ir -l -t TCP_RR -b -v wireguard-lkm
./generate_inventories.py -ir -l -t UDP_RR -b -v wireguard-lkm

# ./generate_inventories.py -ir -w -v wireguard-lkm