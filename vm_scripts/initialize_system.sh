#!/bin/bash -x
echo "Update system and install required software"
sudo apt-get update
sudo apt-get -y full-upgrade
sudo apt-get install -y gfortran g++ make cmake libopenmpi-dev openmpi-bin libnetcdff-dev netcdf-bin libfftw3-dev python3-pip python3-pyqt5 flex bison ncl-ncarg nmap net-tools
sudo apt-get -y autoremove

cat << EOF >  /home/_azbatch/.bash_aliases
#CFLAGS="-O2 -march=native -mtune=native -fopenmp -pipe"
#CXFLAGS="${CFLAGS}"
#CXXFLAGS="${CFLAGS}"
#CPPFLAGS="${CFLAGS}"

export TARGET_BASE_PATH=/mnt/batch/tasks/fsmounts/shared/palmbase/palm

export PATH=/mnt/batch/tasks/fsmounts/shared/palmbase/palm/bin:${PATH}
EOF
chown _azbatch:_azbatchgrp /home/_azbatch/.bash_aliases


echo "Initialization complete!"


