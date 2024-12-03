#!/bin/bash

# Install essential packages
sudo apt install -y intel-media-va-driver intel-opencl-icd intel-gpu-tools mesa-* openal-info libopenal-dev libglfw3-wayland libglfw3-dev p7zip-full vulkan-tools opencl-headers

# Install KDE Plasma Desktop without recommended packages
sudo apt install -y kde-plasma-desktop --no-install-recommends

# Install additional KDE applications
sudo apt install -y firefox-esr plasma-nm plasma-systemmonitor sddm plasma-workspace-wayland ffmpeg* kio-extras dolphin-plugins kimageformat-plugins

# Check if the installation was successful
if [ $? -eq 0 ]; then
  echo "Installation completed successfully!"
else
  echo "Installation failed. Please check the logs for more information."
fi
