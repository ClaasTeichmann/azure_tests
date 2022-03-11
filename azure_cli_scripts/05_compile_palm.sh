#!/bin/bash -x

export run_id="006"

# Create task to create the application zip file
export task_id="palm-compile-task-${run_id}"
export job_id="palm-compile-${run_id}"


cat << EOF >  palm_compile.json
{
    "id": "$task_id",
    "displayName": "$job_id",
    "commandLine": "/bin/bash -c '/mnt/batch/tasks/fsmounts/shared/tasks/compile_palm_${VM_TYPE}.sh'",
    "resourceFiles": [],
    "environmentSettings": [
      {
        "name": "NODES",
        "value": "2"
      },
      {
        "name": "PPN",
        "value": "2"
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

# Create job to create the application packahe
az batch job create --id ${job_id} --pool-id ${pool_id}

# Create a task within the job
az batch task create --task-id ${task_id} --job-id ${job_id} --json-file palm_compile.json

# az batch job delete --job-id ${job_id}

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


