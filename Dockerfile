# FROM ubuntu:16.04
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
# FROM tensorflow/tensorflow:1.1.0-devel-gpu
# FROM nvcr.io/nvidia/tensorflow:17.04

#MAINTAINER Tobias Schneck "tobias.schneck@consol.de"
MAINTAINER Douglas Holt "dholt@nvidia.com"

# Add label to include nvidia-docker volume
LABEL com.nvidia.volumes.needed="nvidia_driver"

### Add paths to nvidia tools
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY :1
ENV VNC_PORT 5901
ENV NO_VNC_PORT 6901
EXPOSE $VNC_PORT $NO_VNC_PORT

ENV HOMELESS /headless
ENV STARTUPDIR /dockerstartup
WORKDIR $HOMELESS

### Envrionment config
ENV DEBIAN_FRONTEND noninteractive
ENV NO_VNC_HOME $HOMELESS/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1280x1024
ENV VNC_PW vncpassword

### Add all install scripts for further steps
ENV INST_SCRIPTS $HOMELESS/install
ADD ./src/common/install/ $INST_SCRIPTS/
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firfox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
# for chrome to work run container with --privileged option
# or use --no-sandbox option otherwise error:
#     Failed to move to new namespace: PID namespaces supported,
#     Network namespace supported, but failed: errno = Operation not permitted
# RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOMELESS/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOMELESS

### Set LD paths to include NVIDIA libraries
RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# USER 1984

# ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
# CMD ["--tail-log"]
CMD ["bash", "--init-file", "/dockerstartup/vnc_startup.sh"]

