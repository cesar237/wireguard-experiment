#! /usr/bin/bash

ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh

if [ -z $1 ]; then
    VERSION=6.1.90
else
    VERSION=$1
fi

FLAVOUR=-xxx
SUFFIX=zip
LINUX=linux-${VERSION}$FLAVOUR.$SUFFIX

# Install dependencies
ssh root@$server "apt-get update && apt-get install zstd git make fakeroot dwarves build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison -y"

# Upload custom linux kernel code
# If $1 is online, then download and 
ssh root@$server "scp $archive_dir/$LINUX /tmp"
# ssh root@$server "cd /tmp && tar -xvf $LINUX"
if [[ "$SUFFIX" == "zip" ]]; then
ssh root@$server "cd /tmp && unzip $LINUX"
else    
ssh root@$server "cd /tmp && tar --extract --zstd --file $LINUX"
fi

# Make
ssh root@$server "cd /tmp/linux-$VERSION && make -j 36 && make modules_install -j 36 && make install" 
