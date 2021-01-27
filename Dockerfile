FROM python:3-slim

ENV USER_NAME=adf
ENV ADF_PATH=/opt/adf

USER root
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt : \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
        bash \
        bison \
        build-essential \
        cmake \
        flex \
        git \
        gperf \
        less \
        libncurses-dev \
        libffi-dev \
        libssl-dev \
        libusb-1.0.0 \
        screen \
        sudo \
        tmux \
# TODO: Check non-1000 UID
 && useradd --create-home \
    --shell /bin/bash \
    --gid staff \
    --groups dialout \
    $USER_NAME \
 && echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/010_no-passwd-local \
 && mkdir "$ADF_PATH" \
 && chown $USER_NAME:staff "$ADF_PATH" \
 && :

# Install esp-adf under non-priviledged user
USER $USER_NAME
RUN : \
 && git clone --recursive https://github.com/espressif/esp-adf.git "$ADF_PATH" \
 && "$ADF_PATH/esp-idf/install.sh" \
 && :

# Bootstrap entrypoint
USER root
RUN : \
 && { echo "#!/bin/bash"; \
      echo "set -e"; \
      echo "source \"$ADF_PATH/esp-idf/export.sh\""; \
      echo "exec \"\$@\""; \
    } > /entrypoint.sh \
 && chmod +x /entrypoint.sh \
 && :
ENTRYPOINT ["/entrypoint.sh"]

USER $USER_NAME
CMD ["bash"]
