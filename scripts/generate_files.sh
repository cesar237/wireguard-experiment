#$1=Number of target nodes and client_nodes
# set -x

ROOT=~/wireguard-experiment

. $ROOT/scripts/global_vars.sh

n=$1

list_nodes() {
    cat $NODEFILE
}

# set server node:
list_nodes | head -1 > $SERVERFILE
# server_prefix=`cat $SERVERFILE`

# set targets node:
list_nodes | head -n $(( n + 1 )) | tail -n $n > $TARGETFILE
# target_prefix=`cat $TARGETFILE`

# set clients nodes:
list_nodes | tail -n $n  > $CLIENTFILE; 
# clients_prefix=`cat $CLIENTFILE`
