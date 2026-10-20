# hadolint global ignore=DL3006,DL3008,DL3013
FROM ros:jazzy
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -y \
  && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  ros-dev-tools \
  ros-jazzy-image-tools \
  imagemagick \
  x11-apps \
  xvfb \
  tmux \
  vim \
  && rm -rf /var/lib/apt/lists/*

COPY src /get-started-ros2/src
WORKDIR /get-started-ros2

RUN apt-get update \
  && rosdep update \
  && rosdep install --ignore-src --from-paths -y src \
  && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# tmux
RUN echo 'set -g mouse on' >> /root/.tmux.conf

# Claude
RUN curl -fsSL https://claude.ai/install.sh | bash

# mise
RUN curl https://mise.run | sh \
  && mise use --global python@latest node@latest rust@latest
RUN echo 'eval "$(mise activate bash)"' >> /root/.bashrc

RUN source /opt/ros/jazzy/setup.bash \
  && colcon build \
  --mixin release compile-commands
  
RUN echo ". /opt/ros/jazzy/setup.bash" >> /root/.bashrc
