# Carla with Lidar Object Detection Setup
## Installation
### Docker Installation
Follow the instructions from [here](https://docs.docker.com/engine/install/ubuntu/) to setup docker on Ubuntu
For ease of use you can also follow the following instructions:
*(These instructions might not be up-to date)*

 1. Set up Docker's `apt` repository.

        # Add Docker's official GPG key:
        sudo apt-get update
        sudo apt-get install ca-certificates curl
	    sudo install -m 0755 -d /etc/apt/keyrings
	    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	    sudo chmod a+r /etc/apt/keyrings/docker.asc
2. Install the Docker packages.

	    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
3. Test if the Docker Engine is running or not:

	    sudo docker run hello-world
4. Create docker group to allow docker to run rootless


	    sudo groupadd docker
    	sudo usermod -aG docker $USER
    	newgrp docker
    Check if this command works: `docker run hello-world`

### Install NVIDIA Container Toolkit
The original installation is present [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
For ease of use you can also follow the following instructions assuming you already have nvidia device driver (nvidia-smi) running on your host system:
*(These instructions might not be up-to date)*

    $ curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    $ sudo apt-get update
    $ sudo apt-get install -y nvidia-container-toolkit
    $ sudo nvidia-ctk runtime configure --runtime=docker
    $ sudo systemctl restart docker
    $ sudo systemctl disable --now docker.service docker.socket

  Restart the system and then execute the following commands:

    $ dockerd-rootless-setuptool.sh install
    $ nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
    $ systemctl --user restart docker
    $ sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place

   To test whether the installation has happened correctly:


    $ docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

You should be able to see nvidia-smi output.

## Setting up Docker images
Next you need to download the following docker images:
1. [Carla Bridge Docker Image](https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/sakshams_iisc_ac_in/EXv9gvfi7g9JlCzZtsSxzDoBIcqoEJFlbwpRWX98KSG1EQ?e=i9nwW7)
2. [Carla Simulator Docker Image](https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/sakshams_iisc_ac_in/EbtdaeUgAkRElFjU6_SA2bMBfWXa7rylLttXlnY33efMwQ?e=b5uGRF)
3. [Object Detection Docker Image]()

### Load the docker images
Execute from the path you downloaded the images from

    $ gunzip -c carla_bridge.tar.gz | docker load
    $ gunzip -c carlasim.tar.gz | docker load
    $ gunzip -c obd_with_carla.tar.gz | docker load

## Running Docker Images

The deployment is split into three docker images: CarlaSimulator, Carla-ROS-Bridge and LiDAR Object Detection ROS node.

1. First start the CARLA image:

	   $ docker run --privileged --gpus all --net=host -e DISPLAY=$DISPLAY -e SDL_VIDEODRIVER=x11 -v /tmp/.X11-unix:/tmp/.X11-unix:rw carlasim/carla:0.9.13 /bin/bash ./CarlaUE4.sh -vulkan
2. Next spinup the CARL-ROS-Bridge Container

       $ docker run -it --net=host --gpus all -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix carla-ros-bridge:noetic
3. Lastly run the object detection node

       $ docker run -it --net=host --gpus all -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix obd_with_carla:latest /bin/zsh

## Miscellaneous

In case the CUDA Memory is filled, chances are the container is still running. To exit the container execute the following command:

    $ docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
