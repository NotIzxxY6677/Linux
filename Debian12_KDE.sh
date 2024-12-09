#!/bin/bash

# Install drivers-related packages
sudo apt install -y intel-media-va-driver intel-opencl-icd intel-gpu-tools mesa-* openal-info libopenal-dev libglfw3-wayland libglfw3-dev p7zip-full vulkan-tools opencl-headers

# Install KDE Plasma Desktop without recommended packages
sudo apt install -y kde-plasma-desktop plasma-discover plasma-discover-backend-fwupd plasma-discover-backend-flatpak --no-install-recommends

# Install additional KDE applications & others
sudo apt install -y sddm plasma-nm plasma-systemmonitor plasma-workspace-wayland ffmpeg* kio-extras kimageformat-plugins dolphin-plugins firefox-esr

# Check if the installation was successful
if [ $? -eq 0 ]; then
  echo "Installation completed successfully!"
else
  echo "Installation failed. Please check the logs for more information."
fi
