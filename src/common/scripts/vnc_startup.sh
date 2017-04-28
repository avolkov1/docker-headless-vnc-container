#!/bin/bash
### every exit != 0 fails the script
# set -e
set -x

if [ ! -f "${HOME}/.config/xfce4/headlessconfig" ]; then
    mkdir -p ${HOME}/.config/xfce4
    \cp -rf ${HOMELESS}/.config/xfce4 ${HOME}/.config
    touch ${HOME}/.config/xfce4/headlessconfig
fi

# should also source $STARTUPDIR/generate_container_user
source $HOMELESS/.bashrc

# add `--skip` to startup args, to skip the VNC startup procedure
if [[ $1 =~ --skip ]]; then
    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi

## write correct window size to chrome properties
# $STARTUPDIR/chrome-init.sh

## resolve_vnc_connection # ip addr show docker0 to enable --net=host case
#VNC_IP=$(ip addr show eth0 || ip addr show docker0 | grep -Po 'inet \K[\d.]+')
VNC_IP=$(ip route get 1 | awk '{print $NF;exit}')

## change vnc password
echo -e "\n------------------ change VNC password  ------------------"
(echo $VNC_PW && echo $VNC_PW) | vncpasswd


## start vncserver and noVNC webclient
$NO_VNC_HOME/utils/launch.sh --vnc $VNC_IP:$VNC_PORT --listen $NO_VNC_PORT &
vncserver -kill :1 || rm -rfv /tmp/.X*-lock /tmp/.X11-unix || echo "remove old vnc locks to be a reattachable container"
vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION
$HOMELESS/wm_startup.sh

## log connect options
echo -e "\n\n------------------ VNC environment started ------------------"
echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"

if [[ $1 =~ -t|--tail-log ]]; then
    # if option `-t` or `--tail-log` block the execution and tail the VNC log
    echo -e "\n------------------ $HOMELESS/.vnc/*$DISPLAY.log ------------------"
    tail -f $HOME/.vnc/*$DISPLAY.log
elif [ -z "$1" ] ; then
    echo -e "..."
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '$@'"
    exec "$@"
fi

