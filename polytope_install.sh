#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"


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
    declare desc="Install all polytope components"
    # BOOT
    # Install ubuntu
    apt-get update && apt-get upgrade -y;
    apt-get install wget proot git -y;
    cd $HOME/polytope;
    git clone https://github.com/MFDGaming/ubuntu-in-termux.git;
    cd ubuntu-in-termux;
    chmod +x ubuntu.sh;
    ./ubuntu.sh;
    cp ~/ubuntu-in-termux/resolv.conf ~/ubuntu-in-termux/ubuntu-fs/etc/;
    # Install ssb in ubuntu
    apt install nodejs;
    apt install npm;
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
    # Send private message to Common Observatory SSB ID with .onion
    node co_private_message.js "$(cat $HOME/../usr/var/lib/tor/ssh/hostname)";
    # SUBSCRIBE TO ENTITY REGISTRY (humans and computers)
    # GIT-SSB PRE-REQS (based on noffle's guide here: https://github.com/noffle/git-ssb-intro)
    # Install ssb-npm-registry
    mkdir -p ~/.ssb/node_modules;
    cd ~/.ssb/node_modules;
    curl -s 'http://localhost:8989/blobs/get/&E+tZfD6eodncvEddM3QAfsmzTJ003jlPGsqFN5TO7sQ=.sha256' | tar xz;
    mv package ssb-npm-registry;
    sbot plugins.enable ssb-npm-registry;
    # TBD set "max": 10000000 in ~/.ssb/config
    # Restart ssb-server
    ssb-server restart;
    # Install ssb-npm tools
    npm install --registry=http://localhost:8043/ -g ssb-npm;
    # INSTALL GIT-SSB
    ssb-npm install -g git-ssb
    # SUBSCRIBE/SYNC CODE REPOS
    # INSTALL GITLAB RUNNER
    # REGISTER GITLAB RUNNER WITH GITLAB SERVER(S)


}

main "$0"