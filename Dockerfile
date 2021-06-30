# References:
# * https://registry.hub.docker.com/_/ros/
# * https://hub.docker.com/r/osrf/ros/
# TODO(ycho): Figure out UID automatically on the fly.

ARG BASE_IMAGE=osrf/ros:melodic-desktop-full
ARG UID=1000
ARG GID=1000

ENV USERNAME=user
FROM ${BASE_IMAGE}

# Install packages
RUN apt-get update && apt-get install -y \
    ros-melodic-moveit \
    tmux \
    python-catkin-tools \
    ssh \
    vim \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Setup GUI access enabled user.
# FIXME(ycho): Perhaps unnecessary since we need to run with
# --privileged option anyways (for network access).
RUN useradd -m ${USERNAME} && \
    usermod -s /bin/bash ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 440 /etc/sudoers.d/${USERNAME} && \
    usermod -u ${UID} ${USERNAME} && \
    usermod -g ${GID} ${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Setup ROS + initialize empty catkin workspace
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    source ~/.bashrc
RUN . /opt/ros/melodic/setup.bash && \
    mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws && \
    catkin_make
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc && \
    source ~/.bashrc

# Add robot hostname resolution
# TODO(ycho): hardcoded ip / hostname. Would this work?
# Alternatively, can we intelligently figure this out on entry_point.sh?
RUN echo '137.68.198.113 SXLS0-201214AB' >> /etc/hosts
