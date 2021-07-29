# IMSquared Docker Configuration

# Docker Installation

* [Install](https://docs.docker.com/engine/install/ubuntu/ )
* [Post-Install](https://docs.docker.com/engine/install/linux-postinstall/) (e.g. to avoid `sudo docker ...`)

# Example command-line instruction

## Build

### Credentials

First, download `id_imm_ed25519` SSH Deployment key from [GDrive](https://drive.google.com/drive/folders/1PyoVKkke-fzMba-0kxxfc8ILP0Klw6QB).

Then, place the file under `.ssh/id_imm_ed25519`. This is required for cloning the repository during the docker image build.

### Build Docker Image

```bash
docker build -t imm-ros .
```

## Run

```bash
./ros-docker.sh
```

# Reference

* [ROS Guide](http://wiki.ros.org/docker/Tutorials/Docker): official guide
* [Blog Post: Docker-And-Ros](https://roboticseabass.com/2021/04/21/docker-and-ros/)
* [Using GUI's with Docker](http://wiki.ros.org/docker/Tutorials/GUI)
