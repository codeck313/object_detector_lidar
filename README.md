OpenPCDet ROS Running and Visualization
---

Dataset: [Full KITTI dataset](https://www.cvlibs.net/datasets/kitti/) (Velodyne-64), teaser bag try [onedrive link: kitti_sequence11_half.bag](https://hkustconnect-my.sharepoint.com/:u:/g/personal/qzhangcb_connect_ust_hk/EXqmutFjAbpPsYVe5r91KXEBhLlqP7anlNBJqTMHIOkfqw?e=RoRVgF) only 876Mb

## Docker
Dependencies, install docker and nvidia-container-toolkit, see [some issues](https://github.com/NVIDIA/nvidia-docker/issues/1238)

```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

Build the Dockerfile

```bash
git clone https://github.com/codeck313/object_detector_lidar.git && cd object_detector_lidar
docker build -t airl/lidar_obj_detector:latest .
```

Run the Docker Image

```bash
xhost +local:docker
docker run -it --net=host --gpus all -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name pcdet_ros lidar_obj_detector:latest /bin/zsh
```

Because it need detect your setups, also you have to run the `setup.py` inside the container

```bash
cd OpenPCDet && python3 setup.py develop
# After screen print: Finished processing dependencies for pcdet==0.6.0

# Test step cp model and test pcd to container:
docker cp PATH/TO/pv_rcnn_8369.pth pcdet_ros:/home/airl/workspace/OpenPCDet/tools/
docker cp PATH/TO/kitti_sequence11_half.bag pcdet_ros:/home/airl/workspace/OpenPCDet_ws

# test demo
cd tools && python3 demo.py --cfg_file cfgs/kitti_models/pv_rcnn.yaml \
    --ckpt pv_rcnn_8369.pth \
    --data_path 000002.bin
```

For ROS, inside container:

```bash
cd /home/airl/workspace/OpenPCDet_ws
catkin build && source devel/setup.zsh
roslaunch openpcdet 3d_object_detector.launch
```
