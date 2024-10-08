#! /usr/bin/bash

ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh

VERSION=6.1.112
FLAVOUR=
SUFFIX=tar.xz
LINUX=linux-$VERSION.$SUFFIX

# Install dependencies
ssh root@$server "apt-get update && apt-get install zstd git make fakeroot dwarves build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison -y"

# Upload custom linux kernel code
# If $1 is online, then download and 
ssh root@$server "scp $archive_dir/$LINUX /tmp"
ssh root@$server "cd /tmp && tar -xvf $LINUX"
# ssh root@$server "cd /tmp && tar --extract --zstd --file linux-6.6.48-vanilla.tar.zst -C / --verbose"

# Make
ssh root@$server "cd /tmp/linux-$VERSION && make modules_install -j 36 && make install" 
