# This Dockerfile is used to build an headles vnc image based on Ubuntu

FROM ubuntu:16.04

MAINTAINER Tobias Schneck "tobias.schneck@consol.de"
ENV REFRESHED_AT 2017-02-14

LABEL com.nvidia.volumes.needed="nvidia_driver"

### NV Stuff
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY :1
ENV VNC_PORT 5901
ENV NO_VNC_PORT 6901
EXPOSE $VNC_PORT $NO_VNC_PORT

ENV HOME /headless
ENV STARTUPDIR /dockerstartup
WORKDIR $HOME

### Envrionment config
ENV DEBIAN_FRONTEND noninteractive
ENV NO_VNC_HOME $HOME/noVNC
ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1280x1024
ENV VNC_PW vncpassword

### Add all install scripts for further steps
ENV INST_SCRIPTS $HOME/install
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
RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### NV Stuff
RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

USER 1984

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--tail-log"]
