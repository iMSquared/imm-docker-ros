# References:
# * https://registry.hub.docker.com/_/ros/
# * https://hub.docker.com/r/osrf/ros/
# TODO(ycho): Figure out UID automatically on the fly.

ARG BASE_IMAGE=osrf/ros:melodic-desktop-full
ARG UID=1000
ARG GID=1000

FROM ${BASE_IMAGE}

ENV USERNAME=user
# NOTE(ycho): Re-declare `ARG` for visibility.
ARG UID
ARG GID

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
RUN echo "useradd -m -s /bin/bash ${USERNAME}"
RUN useradd -m -s /bin/bash ${USERNAME} && \
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

# required for building with robotnik_base_hw_lib
# RUN sudo apt-get install ros-melodic-libpcan
# RUN sudo dpkg -i ros-melodic-robotnik-base-hw-lib_1.0.0-0bionic_amd64.deb ros-melodic-robotnik-msgs_1.0.0-0bionic_amd64.deb 
RUN rosdep update
# OR, add <build_depend>libpcan</build_depend> in robotnik*/package.xml
# and CATKIN_FIND_PACKAGE(... libpcan)
# and INCLUDE_DIRECTORIES(... "/opt/ros/melodic/include/libpcan/")
# some combination of the above works. My guess is rosdep/rosmake doesn't do much.

# Clone our workspace.
RUN cd ~/catkin_ws/src && \
    git clone https://github.com/imsquared/imm-summit-packages.git --depth 1 -b full

# Build ...
# RUN rosdep install --from-paths src --ignore-src -y --skip-keys='robotnik_base_hw_lib' --skip-keys='robotnik_pose_filter' --skip-keys='robotnik_locator'
RUN sudo apt-get update && sudo apt-get install -y \
    ros-melodic-libpcan
# NOTE(ycho): Not directly running install_debs.sh since it doesn't include proper cli flags.
RUN sudo apt-get install -y libgazebo9-dev ros-melodic-gazebo-dev
RUN cd ~/catkin_ws/src/imm-summit-packages/deb && \
    sudo apt-get update && \
    sudo apt-get install -y \
    $(cat ./install_debs.sh | grep deb$ | awk '{print "./"$4}' | grep -v 'melodic-gazebo') \
    && rm -rf /var/lib.apt/lists/*
# RUN rosdep install libpcan && rosmake libpcan
RUN cd ~/catkin_ws && rosdep install --from-paths src --ignore-src -y \
    --skip-keys='robotnik_base_hw_lib' \
    --skip-keys='robotnik_pose_filter' \
    --skip-keys='robotnik_locator'
RUN . /opt/ros/melodic/setup.bash && \
    cd ~/catkin_ws && \
    catkin_make
