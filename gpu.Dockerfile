FROM imm-ros

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ubuntu-drivers-common \
    && rm -rf /var/lib/apt/lists/*

#RUN apt-get update && \
#    ubuntu-drivers autoinstall \
#    && rm -rf /var/lib/apt/lists/*

# FIXME(ycho): How to force identical version with host?
# and/or is it necessary to do so?
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nvidia-driver-460 \
    && rm -rf /var/lib/apt/lists/*

# FIXME(ycho): Hardcoded `user`
USER user

ENTRYPOINT ["/bin/bash"]
