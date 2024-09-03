# Configure iproute
for target in `cat TARGETS`; do
	target_ip=`nslookup $target | head -n 5 | tail -n 1 | awk '{print $2}'`
	# ip route del $target_ip dev eno1
	ip route add $target_ip dev eno1
done
