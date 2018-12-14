#!/data/data/com.termux/files/usr/bin/sh -ex

# Optionally install SSH keys from a supplied list of GITHUB_USERS (or use arguments to this script to enumerate these)
GITHUB_USERS=${GITHUB_USERS:-${$@:-ianblenke}}

# Install dependencies
which bash > /dev/null 2>&1 || pkg install bash
which curl > /dev/null 2>&1 || pkg install curl
which git > /dev/null 2>&1 || pkg install git
which rsync > /dev/null 2>&1 || pkg install rsync
which sshd > /dev/null 2>&1 || pkg install openssh
which tor > /dev/null 2>&1 || pkg install tor
which ipfs > /dev/null 2>&1 || pkg install ipfs

if [ -n "$GITHUB_USERS" ]; then

  # Add ssh keys from github user ianblenke
  touch $HOME/.ssh/authorized_keys
  (
    cat $HOME/.ssh/authorized_keys
    for user in $GITHUB_USERS; do
      curl -sL https://github.com/${user}.keys
    done
  ) | sort > $HOME/.ssh/authorized_keys.new
  mv $HOME/.ssh/authorized_keys.new ~/.ssh/authorized_keys
  chmod 700 $HOME/.ssh
  chmod 600 $HOME/.ssh/authorized_keys

fi

if [ ! -d $HOME/termux-tor-ssh ]; then
  git clone https://github.com/ianblenke/termux-tor-ssh $HOME/termux-tor-ssh
fi

cd $HOME/termux-tor-ssh
rsync -SHPaxq .bash_profile $HOME/.bash_profile
rsync -SHPaxq .sv/ $HOME/.sv
rsync -SHPaxq usr/ $HOME/../usr/

export SVDIR=$HOME/.sv

sv up tor
sv up sshd
sv up ipfs

sleep 1

if [ -f $HOME/../usr/var/lib/tor/ssh/hostname ]; then
  cat $HOME/../usr/var/lib/tor/ssh/hostname
fi

