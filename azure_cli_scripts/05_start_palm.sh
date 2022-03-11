#!/bin/bash -x

# Variables
source variables.sh

export simulation_id="007"
export try_id="002"

# Create task to create the application zip file
export task_id="palm-sim-task-${simulation_id}-${try_id}"
export job_id="palm-sim-${simulation_id}"


cat << EOF >  palm_run.json
{
    "id": "$task_id",
    "displayName": "$job_id",
    "commandLine": "/bin/bash -c '/mnt/batch/tasks/fsmounts/shared/vm_scripts/run_example_cbl.sh'",
    "resourceFiles": [],
    "environmentSettings": [
      {
        "name": "NODES",
        "value": "2"
      },
      {
        "name": "PPN",
        "value": "1"
      }
    ],
    "constraints": {
      "maxWallClockTime": "P10675199DT2H48M5.477S",
      "maxTaskRetryCount": 2,
      "retentionTime": "P7D"
    },
    "userIdentity": {
      "autoUser": {
        "scope": "pool",
        "elevationLevel": "nonadmin"
      }
    },
    "multiInstanceSettings": {
      "coordinationCommandLine": "groups && /bin/bash -c env",
      "numberOfInstances": 2,
      "commonResourceFiles": []
    }
  }
EOF

# Create job to create the application package
az batch job create --id ${job_id} --pool-id ${pool_id}

# Create a task within the job
az batch task create --task-id ${task_id} --job-id ${job_id} --json-file palm_run.json

# az batch job delete --job-id ${job_id}


    # --command-line "/bin/bash -c 'wget -L https://raw.githubusercontent.com/SebaStad/azure_tests/main/palm_tests_palm_installed.sh;chmod u+x palm_tests_palm_installed.sh;./palm_tests_palm_installed.sh'"
    # --command-line "/bin/bash -c 'wget -L https://raw.githubusercontent.com/SebaStad/azure_tests/main/palm_tests_palm_installed.sh;chmod u+x palm_tests_palm_installed.sh;./palm_tests_palm_installed.sh'"
    #    --command-line "/bin/bash -c 'wget -L https://raw.githubusercontent.com/kaneuffe/azure-batch-workshop/main/create_palm.sh;chmod u+x create_app_zip.sh;./create_app_zip.sh'"

# Wait for the task to finish
state=$(az batch task show --job-id ${job_id} --task-id ${task_id} --query 'state')
echo "Job task status"
echo $state
while [[ $state != *"completed"* ]]
do
    state=$(az batch task show --job-id ${job_id} --task-id ${task_id} --query 'state')
    echo $state
    sleep 1
done


