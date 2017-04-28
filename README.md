# Ubuntu desktop Docker container image with VNC

Ubuntu 16.04 container running the XFCE window manager with GPU support
(via nvidia-docker).

The Docker image is installed with the following components:

* Desktop environment [**Xfce4**](http://www.xfce.org)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/kanaka/noVNC) - HTML5 VNC client (default http port `6901`)
* Browsers:
  * Mozilla Firefox

## Build
Build the docker container via:

    docker build -t ubuntu-vnc-xfce4 .

## Usage
The vnc-server is exposed on port `5901` and vnc web access port `6901`. The
option ```--net=host``` is used below, alternatively use
```-p 5901:5901 -p 6901:6901```. It is possible to use the container as root,
which is highly discouraged.

    nvidia-docker run --rm -d -t --net=host ubuntu-vnc-xfce4  # as root DON'T DO THIS

Running as root is not recommended. A better approach is to run as a user with
home directory mounted.

    nvidia-docker run --name=mydesk --rm -d -t -u $(id -u):$(id -g) -e USER=$USER\
      -e HOME=$HOME -v $HOME:$HOME --net=host -w $PWD ubuntu-vnc-xfce4

An even better approach and the one recommended is to run using
[***luda***](https://github.com/ryanolson/luda). The luda docker wrapper will
properly map in the user and group of the host system into the container.

    luda -d "--name=mydesk --rm -d -t" --net=host \
      ubuntu-vnc-xfce4 "bash --init-file /dockerstartup/vnc_startup.sh"

When using luda the entrypoint/cmd has to be specified explicitly:
```"bash --init-file /dockerstartup/vnc_startup.sh"```.

When the home directory is mounted into the container the xfce4 desktop settings
will persist if the container is restarted.

Download a VNC client for your system from
[RealVnc](https://www.realvnc.com/download/viewer/), or use a web-browser.

=> connect via __VNC viewer `hostip:5901`__, default password: `vncpassword`

=> connect via __noVNC HTML5 client__: [http://hostip:6901/?password=vncpassword]()


## Troubleshooting
If the mouse is not working in noVNC on touchscreen PCs disable "Touch Events
API" in Chrome ```chrome://flags```.

## Hints

### Override VNC environment variables
The following VNC environment variables can be overwritten at the `docker run`
phase to customize your desktop environment inside the container:
* `VNC_COL_DEPTH`, default: `24`
* `VNC_RESOLUTION`, default: `1280x1024`
* `VNC_PW`, default: `my-pw`

The resolution can be changed after the container is launched via xrandr as well.

#### 1) Example: Override the VNC password
Overwrite the value of the environment variable `VNC_PW`. For example in
the docker run command:

    luda -d "--name=mydesk --rm -d -t" --net=host -e VNC_PW=my-pw \
      ubuntu-vnc-xfce4 "bash --init-file /dockerstartup/vnc_startup.sh"

#### 2) Example: Override the VNC resolution
Overwrite the value of the environment variable `VNC_RESOLUTION`. For
example in the docker run command:

    luda -d "--name=mydesk --rm -d -t" --net=host -e VNC_RESOLUTION=800x600 \
      ubuntu-vnc-xfce4 "bash --init-file /dockerstartup/vnc_startup.sh"

Or use xrandr once inside the container VNC session.

