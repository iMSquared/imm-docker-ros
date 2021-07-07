FROM osrf/ros:melodic-desktop-full
ENV USERNAME=user
# RUN apt-get update && apt-get install -y \
#     <package> && \
#     rm -rf /var/lib/apt/lists/*
RUN useradd -m ${USERNAME} && \
    usermod -s /bin/bash ${USERNAME} && \ 
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 440 /etc/sudoers.d/${USERNAME} && \
    usermod -u 1000 ${USERNAME} && \
    usermod -g 1000 ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}
SHELL ["/bin/bash", "-c"]
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    source ~/.bashrc
