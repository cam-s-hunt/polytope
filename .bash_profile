export SVDIR=$HOME/.sv

($HOME/bin/service-daemon start >/dev/null 2>&1 & )

sleep 1

sv up sshd
sv up tor

if [ -f $HOME/../usr/var/lib/tor/ssh/hostname ]; then
  echo "For remote access, use:"
  echo ""
  echo "    ssh $(whoami)@$(cat $HOME/../usr/var/lib/tor/ssh/hostname)"
  echo ""
fi

if [ -f $HOME/polytope/ubuntu-in-termux/ubuntu.sh]; then
  $HOME/polytope/ubuntu-in-termux/ubuntu.sh
else
  echo -n "Install Polytope [Y/n]"
  read answer
  if [ "$answer" != "${answer#[Yy]}" ] ;then
    $HOME/polytope/polytope_install.sh
  else
    echo No
fi
  