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

SHELL ["/bin/bash", "-c"]
# Patch source as requested by board logs
# I (367) AUDIO_THREAD: The media_task task allocate stack on external memory
# E (367) AUDIO_THREAD: Not found right xTaskCreateRestrictedPinnedToCore.
# Please enter IDF-PATH with "cd $IDF_PATH" and apply the IDF patch with "git apply $ADF_PATH/idf_patches/idf_v3.3_freertos.patch" first
# 
# E (387) AUDIO_THREAD: Error creating RestrictedPinnedToCore media_task
# E (397) ESP_AUDIO_CTRL: Error create media_task
# I (397) AUDIO_HAL: Codec mode is 3, Ctrl:1
# RUN : \
#  && . "$ADF_PATH/esp-idf/export.sh" \
#  && cd $IDF_PATH \
#  && git apply "$ADF_PATH/idf_patches/idf_v3.3_freertos.patch" \
#  && :

# Bootstrap entrypoint
USER root
RUN : \
 && { echo "#!/bin/bash"; \
      echo "set -e"; \
      echo "source \"$ADF_PATH/esp-idf/export.sh\""; \
      echo "# Image set-up at run-time"; \
      echo "if [ -e /project/docker-prep ]; then"; \
      echo "  if [ -x /project/docker-prep ]; then"; \
      echo "    /project/docker-prep"; \
      echo "  else"; \
      echo "    echo \"Warning: /project/docker-prep is not executable!\""; \
      echo "  fi"; \
      echo "fi"; \
      echo ""; \
      echo "exec \"\$@\""; \
    } > /entrypoint.sh \
 && chmod +x /entrypoint.sh \
 && :
ENTRYPOINT ["/entrypoint.sh"]

USER $USER_NAME
CMD ["bash"]
