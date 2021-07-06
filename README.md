# IMSquared Docker Configuration

# Docker Installation

* [Install](https://docs.docker.com/engine/install/ubuntu/ )
* [Post-Install](https://docs.docker.com/engine/install/linux-postinstall/) (e.g. to avoid `sudo docker ...`)

# Example command-line instruction

## Build

```bash
docker build -t imm-ros . # -f Dockerfile
```

## Run

```bash
docker run --network host -it imm-ros /bin/bash
```

# Reference

* [ROS Guide](http://wiki.ros.org/docker/Tutorials/Docker): official guide
* [Blog Post: Docker-And-Ros](https://roboticseabass.com/2021/04/21/docker-and-ros/)
