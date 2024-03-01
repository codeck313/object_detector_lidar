FROM nvidia/cuda:11.6.2-devel-ubuntu20.04

# Just in case we need it
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y --no-install-recommends git curl wget git zsh tmux vim g++
# needs to be done before we can apply the patches

# install zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p https://github.com/agkozak/zsh-z \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting


# ==========> INSTALL ROS noetic <=============
RUN apt update && apt install -y curl lsb-release
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update && apt install -y ros-noetic-desktop-full
RUN apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential -y \
    && rosdep init && rosdep update
RUN echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc
RUN echo "source /opt/ros/noetic/setup.bashrc" >> ~/.bashrc

# =========> INSTALL OpenPCDet <=============
RUN apt update && apt install -y python3-pip
RUN pip3 install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116

RUN pip3 install spconv-cu116
RUN apt update && apt install -y python3-setuptools
RUN mkdir -p /home/airl/workspace
WORKDIR /home/airl/workspace
RUN git clone https://github.com/Kin-Zhang/OpenPCDet.git
RUN cd OpenPCDet && pip3 install -r requirements.txt
RUN pip3 install pyquaternion numpy==1.23 pillow==8.4 open3d #mayavi 

# RUN cd OpenPCDet && python3 setup.py develop # need run inside the container!!!

# =========> Clone ROS Package <============
RUN apt update && apt install ros-noetic-ros-numpy ros-noetic-vision-msgs
RUN git clone https://github.com/Kin-Zhang/OpenPCDet_ros.git /home/airl/workspace/OpenPCDet_ws/src/OpenPCDet_ros
RUN apt-get install -y ros-noetic-catkin python3-catkin-tools
