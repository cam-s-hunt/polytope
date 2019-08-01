#!/usr/bin/env bash
set -o errexit;
set -o nounset;
set -o pipefail;
# set -o xtrace

# Set magic variables for current file & dir
#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")";
#__base="$(basename ${__file} .sh)";
#__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app;

#arg1="${1:-}";


# $(command) instead of `command`
# use readonly to declare static variables, otherwise use local
# [[]] instead of [] or test
# absolute paths, $PWD, ./
# always double-quote variable references: cp -- "$file" "$destination"
# main(){
#    declare desc="description" 
#    declare arg1="$1"
#    command1; 
#    command2; 
#    }

main() {
    declare desc="Install all polytope components";
    # BOOT
    # Clone repo
    apt-get update && apt-get upgrade -y;
    apt-get install git -y; 
    cd $HOME;
    git clone https://github.com/cam0sum/polytope.git;
    # Configure SSB Hidden Service
    mkdir -p $HOME/../usr/var/lib/tor/ssb; 
    rsync -SHPaxq $HOME/polytope/usr/etc/torrc.d/ssb_hiddenservice $HOME/../usr/etc/torrc.d;
    sv restart tor;
    sed -i "s/\"\"/`cat $HOME/../usr/var/lib/tor/ssb/hostname`/g" $HOME/polytope/etc/config;
    # Install ubuntu
    apt-get install wget proot -y;
    cd $HOME;
    git clone https://github.com/MFDGaming/ubuntu-in-termux.git;
    cd ubuntu-in-termux;
    chmod +x ubuntu.sh;
    ./ubuntu.sh;
    cp ~/ubuntu-in-termux/resolv.conf ~/ubuntu-in-termux/ubuntu-fs/etc/;
    mkdir -p $HOME/ubuntu-in-termux/ubuntu-fs/root/.ssb/;
    cp $HOME/polytope/etc/config $HOME/ubuntu-in-termux/ubuntu-fs/root/.ssb/;
    cp $HOME/polytope/etc/hosts $HOME/ubuntu-in-termux/ubuntu-fs/etc/;
    ./start.sh <<EOF
    # Attempt to install ssb in Ubuntu
    apt update && apt upgrade -y;
    apt install nodejs npm -y;
    npm install npm -g;
    npm install --global ssb-server;
    # Start ssb server
    ssb-server start;
    # ENROLL NODE
    # Install ssb-private
    sbot plugins.install ssb-private;
    # Install peer-invites
    sbot plugins.install ssb-device-address;
    sbot plugins.install ssb-identities;
    sbot plugins.install ssb-peer-invites;
    # Restart ssb-server
    ssb-server restart;
    # Send private message to Common Observatory SSB ID with .onion
    #node co_private_message.js "$(cat $HOME/../usr/var/lib/tor/ssh/hostname)";
    # SUBSCRIBE TO ENTITY REGISTRY (humans and computers)
    # GIT-SSB PRE-REQS (based on noffle's guide here: https://github.com/noffle/git-ssb-intro)
    # Connect to some clearnet hubs to increase the likelihood we can get npms
    sbot invite.accept ssb.webcookies.pub:8008:@VktnvwfOPj7vOL1BqGOv5CWUhNXG3jywAueCzH8QxPw=.ed25519~TSG+yJCKcOE68DrVUIyIfmtRTwco8r9F1+cLcz2kI2Y=
    sbot invite.accept butt.caasih.net:8008:@QIlKZ8DMw9XpjpRZ96RBLpfkLnOUZSqamC6WMddGh3I=.ed25519~rbnx8u8T5SpxKl1h0GoAMXo27nhveNQwA8lnhc7+P8g=
    sbot invite.accept bar.quark.rocks:8008:@f7ZttK5cvdBL/t6utZYyP/rSRqgnrsB23yFWr5/J83s=.ed25519~LS0pGT7H4t8/YGKPluY+b66vW2BGxFuBQesyLgQ2Ih0=
    sbot invite.accept usw.ssbpeer.net:8008:@MauI+NQ1dOg4Eo5NPs4OKxVQgWXMjlp5pjQ87CdRJtQ=.ed25519~QUE8KBMshrNjsQf/I2F599qgG2pKgnuuU90LgpcHZY4=
    sbot gossip.connect ssb.celehner.com:8008~shs:5XaVcAJ5DklwuuIkjGz4lwm2rOnMHHovhNg7BFFnyJ8
    # Install ssb-npm-registry
    sbot plugins.install ssb-npm-registry --from 'http://localhost:8989/blobs/get/&2afFvk14JEObC047kYmBLioDgMfHe2Eg5/gndSjPQ1Q=.sha256';
    sbot plugins.enable ssb-npm-registry;
    # Restart ssb-server
    ssb-server restart;
    # Install ssb-npm tools
    npm install --registry=http://localhost:8043/ -g ssb-npm;
    # INSTALL GIT-SSB
    ssb-npm install --global git-ssb;
    # SUBSCRIBE/SYNC CODE REPOS
    # INSTALL GITLAB RUNNER
    # REGISTER GITLAB RUNNER WITH GITLAB SERVER(S)
EOF

}

main "$0"
