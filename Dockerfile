# syntax=docker/dockerfile:experimental
# References:
# * https://registry.hub.docker.com/_/ros/
# * https://hub.docker.com/r/osrf/ros/

ARG BASE_IMAGE=osrf/ros:melodic-desktop-full
ARG UID=1000
ARG GID=1000

FROM ${BASE_IMAGE}

ENV USERNAME=user
# NOTE(ycho): Re-declare `ARG` for visibility.
ARG UID
ARG GID

# Install dev packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    ssh \
    vim \
    iputils-ping \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# Install ROS packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-melodic-moveit \
    ros-melodic-libpcan \
    python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# Setup GUI access enabled user.
RUN echo "useradd -m -s /bin/bash ${USERNAME}"
RUN useradd -m -s /bin/bash ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 440 /etc/sudoers.d/${USERNAME} && \
    usermod -u ${UID} ${USERNAME} && \
    usermod -g ${GID} ${USERNAME}

# NOTE(ycho): As the root user, mount host ssh and clone our packages into `tmp`.
RUN mkdir -p -m 0600 "/root/.ssh" \
    && ssh-keyscan github.com | sudo tee -a "/root/.ssh/known_hosts"
RUN --mount=type=ssh git clone git@github.com:iMSquared/imm-summit-packages.git --depth 1 -b full \
    "/tmp/imm-summit-packages/"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Setup ROS + initialize empty catkin workspace
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN echo "${PATH}"
RUN . /opt/ros/melodic/setup.bash && \
    mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws && \
    catkin init && \
    catkin build
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

# Required for building with robotnik_base_hw_lib
RUN rosdep update

# NOTE(ycho): --mount=type=ssh,uid=${UID} doesn't work
# Tracked Issue: https://github.com/moby/buildkit/issues/815
# Until then, we need to clone as root, chown then copy the resulting directory to workspace.
# When resolved, use the following instead of the workaround:
# RUN --mount=type=ssh mkdir -p -m 0600 "~/.ssh" \
#     && ssh-keyscan github.com | sudo tee -a "~/.ssh/known_hosts"
# RUN --mount=type=ssh git clone git@github.com:iMSquared/imm-summit-packages.git --depth 1 -b full \
#     "~/catkin_ws/src/imm-summit-packages/"
RUN sudo chown ${USERNAME} -R /tmp/imm-summit-packages && \
    mv /tmp/imm-summit-packages ~/catkin_ws/src/

# Build ...
# RUN rosdep install --from-paths src --ignore-src -y --skip-keys='robotnik_base_hw_lib' --skip-keys='robotnik_pose_filter' --skip-keys='robotnik_locator'

# NOTE(ycho): Not directly running install_debs.sh since it doesn't include proper cli flags.
# FIXME(ycho): Monkey-patched gazebo dependencies, will not work!!!
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    libgazebo9-dev \
    ros-melodic-gazebo-dev

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
    . ~/catkin_ws/devel/setup.bash && \
    cd ~/catkin_ws && \
    catkin build
ENTRYPOINT ["/bin/bash"]
