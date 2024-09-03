#! /usr/bin/bash

ROOT=~/wireguard-experiment
. $ROOT/scripts/global_vars.sh

VERSION=6.6.48
FLAVOUR=vanilla
LINUX=linux-$VERSION-$FLAVOUR


# Install dependencies
ssh root@$server "apt-get update && apt-get install zstd git make fakeroot dwarves build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison -y"

# Upload custom linux kernel code
ssh root@$server "scp $archive_dir/linux-$VERSION-$FLAVOUR.zst /tmp"
ssh root@$server "cd /tmp && tar --extract --zstd --file linux-6.6.48-vanilla.tar.zst -C / --verbose"

# Make
ssh root@$server "cd /usr/src/linux-$VERSION && make modules_install -j 36 && make install" 
