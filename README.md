# IMSquared Docker Configuration

# Docker Installation

* [Install](https://docs.docker.com/engine/install/ubuntu/ )
* [Post-Install](https://docs.docker.com/engine/install/linux-postinstall/) (e.g. to avoid `sudo docker ...`)

# Example command-line instruction

## Build

### Build Docker Image

```bash
./build.sh
```

## Run ROS-enabled container

```bash
./ros-docker.sh
```

## Running Gazebo simulation

```bash
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-*-controllers \
    ros-${ROS_DISTRO}-gazebo-ros-control \
    && rm -rf /...

RUN mkdir -p ~/.gazebo && \
    git clone https://github.com/osrf/gazebo_models.git -depth 1 ~/.gazebo/models
```

# Reference

* [ROS Guide](http://wiki.ros.org/docker/Tutorials/Docker): official guide
* [Blog Post: Docker-And-Ros](https://roboticseabass.com/2021/04/21/docker-and-ros/)
* [Using GUI's with Docker](http://wiki.ros.org/docker/Tutorials/GUI)
* [Private Git Repo with Docker](https://vsupalov.com/better-docker-private-git-ssh/)
