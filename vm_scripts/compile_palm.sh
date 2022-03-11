#!/usr/bin/bash -x

module load gcc-9.2.0
module load mpi/hpcx

#CFLAGS="-O2 -march=native -mtune=native -fopenmp -pipe"
#CXFLAGS="${CFLAGS}"
#CXXFLAGS="${CFLAGS}"
#CPPFLAGS="${CFLAGS}"

export TARGET_PATH=${TARGET_BASE_PATH}/current_version
export PALM_TAR=palm_model_system-v21.10.tar.bz2
export PALM_SOURCE_PATH=palm_model_system-v21.10

echo "Downloading palm..."
mkdir -p ${TARGET_BASE_PATH}
mkdir -p ${TARGET_PATH}
cd ${TARGET_BASE_PATH}

if [ -f ${PALM_TAR} ]
then
  echo "${PALM_TAR} already exists."
else
  wget -nc https://gitlab.palm-model.org/releases/palm_model_system/-/archive/v21.10/${PALM_TAR}
  tar -xjf ${PALM_TAR}
fi

echo "Compiling palm"
cd ${PALM_SOURCE_PATH}

bash install -p ${TARGET_PATH}
export PATH=${TARGET_PATH}/bin:${PATH}

echo "Installed and compiled palm"
