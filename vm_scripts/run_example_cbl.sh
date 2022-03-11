#!/usr/bin/bash -x

## export TARGET_BASE_PATH=/mnt/batch/tasks/fsmounts/shared/palmbase/palm

export PATH=${TARGET_BASE_PATH}/current_version/bin:$PATH

#export RUN_PATH=/mnt/batch/tasks/fsmounts/shared/runs/user_0001/
#export TARGET_BASE_PATH=/mnt/batch/tasks/fsmounts/shared/palmbase/palm
#export TARGET_PATH=${TARGET_BASE_PATH}/current_version
#export PALM_TAR=palm_model_system-v21.10.tar.bz2
#export PALM_SOURCE_PATH=palm_model_system-v21.10

export PALM_PATH=${TARGET_BASE_PATH}/current_version
export RUN_PATH=${TARGET_BASE_PATH}/current_version
export PALM_SOURCE=${TARGET_BASE_PATH}/palm_model_system-v21.10

echo "Copying files"
cd ${RUN_PATH}

echo "Files to setup PALM"

#cp ${PALM_PATH}/.palm.config.default ${RUN_PATH}

echo "Files for the run"

mkdir -p ${RUN_PATH}/JOBS/example_cbl/INPUT
mkdir -p ${RUN_PATH}/JOBS/example_cbl/OUTPUT
mkdir -p ${RUN_PATH}/JOBS/example_cbl/MONITORING

cp ${PALM_SOURCE}/packages/palm/model/tests/cases/example_cbl/INPUT/example_cbl_p3d ${RUN_PATH}/JOBS/example_cbl/INPUT/

echo "Starting palm"
palmrun -a "d3#" -x -X 4 -T 2 -v -r example_cbl

echo "Simulation results"
filepath_results=$(ls ${RUN_PATH}/JOBS/example_cbl/OUTPUT)
echo $filepath_results



