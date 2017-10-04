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

    nvidia-docker run --name=mydesk -d -t -u $(id -u):$(id -g) -e USER=$USER \
      -e HOME=$HOME -v $HOME:$HOME --net=host -w $PWD ubuntu-vnc-xfce4

To stop the container when done using it run:

    docker stop mydesk && docker rm mydesk

When the home directory is mounted into the container the xfce4 desktop settings
will persist when the container is restarted.

Download a VNC client for your system from
[RealVnc](https://www.realvnc.com/download/viewer/), or use a web-browser.

=> connect via __VNC viewer `hostip:5901`__, default password: `vncpassword`

=> connect via __noVNC HTML5 client__: [http://hostip:6901/?password=vncpassword]()

Within the container once connected with VNC or noVNC, run `nvidia-smi` command
to see the GPUs. If the `nvidia-smi` command fails with message:
```
NVIDIA-SMI couldn't find libnvidia-ml.so library in your system...
```

Then run ldconfig command as follows:
```bash
docker exec -it -u root mydesk bash -c 'ldconfig'
```

Afterwards the `nvidia-smi` command should work within the container in the VNC
session.


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

    nvidia-docker run -d -t --name=mydesk --net=host \
      -u $(id -u):$(id -g) -e HOME=$HOME -e USER=$USER -v $HOME:$HOME \
      -e VNC_PW=my-pw \
      -w $HOME ubuntu-vnc-xfce4

#### 2) Example: Override the VNC resolution
Overwrite the value of the environment variable `VNC_RESOLUTION`. For
example in the docker run command:

    nvidia-docker run -d -t --name=mydesk --net=host \
      -u $(id -u):$(id -g) -e HOME=$HOME -e USER=$USER -v $HOME:$HOME \
      -e VNC_RESOLUTION=800x600 \
      -w $HOME ubuntu-vnc-xfce4

Or use xrandr once inside the container VNC session.


## Experimental: Running docker from VNC container
Using a few additional options when starting up this VNC container it is
possible to launch other docker containers. For example if you are using the
VNC container as an IDE with IDE tools, but woud like to then run a docker
container. Docker enabled VNC container command:

    nvidia-docker run --name=mydesk -d -t -u $(id -u):$(id -g) -e USER=$USER \
      -e HOME=$HOME -v $HOME:$HOME --net=host \
      --hostname $(hostname)_mydesk \
      --group-add $(stat -c %g /var/run/docker.sock) \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -w $HOME ubuntu-vnc-xfce4

Once the container is launched and connected with VNC, open a terminal and run
a container command. Example:

```
nvidia-docker run --rm --name=tf_test \
    tensorflow/tensorflow:1.2.1-devel-gpu python -c '
import tensorflow as tf
print("TF version: {}".format(tf.__version__))
from tensorflow.python.client import device_lib
local_device_protos = device_lib.list_local_devices()
gpus_list = [x.name for x in local_device_protos if x.device_type == "GPU"]
print("Available GPUs: {}".format(gpus_list))'
```

Or an interactive session in a container in the VNC. Open a terminal and run:

```
tmpdir=${HOME}/tmp
mkdir -p $tmpdir
# Trick to make yourself appear in the container and run with your uid/gid.
getent group > ${tmpdir}/group
getent passwd > ${tmpdir}/passwd

nvidia-docker run --rm --name=tf_test -ti \
    -u $(id -u):$(id -g) -e HOME=$HOME -e USER=$USER -v $HOME:$HOME \
    -v ${tmpdir}/group:/etc/group -v ${tmpdir}/passwd:/etc/passwd \
    --hostname $(hostname)_tftest \
    tensorflow/tensorflow:1.2.1-devel-gpu
```

The containers being launched from the VNC container are external to the vnc
container itself in the sense that a directory not mapped into the vnc container
can still be mapped into the container being launched. Say there is a directory
`/datasets` that was not mounted during vnc-container launch. That directory
can still be mapped to the containers. Example:

```
tmpdir=${HOME}/tmp
mkdir -p $tmpdir
# Trick to make yourself appear in the container and run with your uid/gid.
getent group > ${tmpdir}/group
getent passwd > ${tmpdir}/passwd

nvidia-docker run --rm --name=tf_test \
    -u $(id -u):$(id -g) -e HOME=$HOME -e USER=$USER -v $HOME:$HOME \
    -v ${tmpdir}/group:/etc/group -v ${tmpdir}/passwd:/etc/passwd \
    -v /datasets:/datasets \
    tensorflow/tensorflow:1.2.1-devel-gpu bash -c \
'ls -l /datasets'
```

