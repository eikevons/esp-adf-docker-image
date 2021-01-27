# ESP-ADF docker image

This project provides a containerized ESP-ADF environment.

`run-esp-adf-builder.sh` wraps the `docker run` command on the host machine.

# Usage

## Build the image

`make image`

## Run the image

`./run-esp-adf-builder.sh [PATH/TO/YOUR/ESP-ADF/PROJECT]`

- If the path to the ESP-ADF project directory is omitted, the current
  directory is used. The project-directry is 
- The script will pass the first USB-tty it finds through to the container.
- The container will not be removed automatically.
- The container will be named `esp-adf-dev`.
