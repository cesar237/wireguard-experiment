# $1 is 0 or 1 for deactivated and activated core
# $2 is the index of the cpu core, starting with 0
# note: cpu0 is not deactivable

echo $1 > /sys/devices/system/cpu/cpu$2/online
