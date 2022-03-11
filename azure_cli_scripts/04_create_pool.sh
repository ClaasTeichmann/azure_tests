#!/bin/bash -x

# Variables
#source variables_current.sh

# Poolvm size; F2; siehe bezeichungen;

compute_subnet_id="/subscriptions/${subscription_id}/resourceGroups/${batch_rg}/providers/Microsoft.Network/virtualNetworks/${batch_vnet_name}/subnets/${compute_subnet_name}"
# pool_id="batch-ws-pool"
nfs_share_hostname="${nfs_storage_account_name}.file.core.windows.net"
nfs_share_directory="/${nfs_storage_account_name}/shared"

# Zur Kontrolle Ausgabe der Variablen:
echo $compute_subnet_id
echo $POOL_VM_SIZE
echo $nfs_share_hostname
echo $nfs_share_directory


# Create the pool definition JSON file
# Define the batch pool

# Python: kann man das json file evtl hinlegen und dann einfach anpassen
# evtl gar nicht neue VM/ aufstellen für PALM, sondern PALM in den shared storage legen

# We create the pool
# * starting with a ubuntu 20.04 server
# * Update and upgrade
# * Install required software

cat << EOF >  ${pool_id}.json
{
  "id": "$pool_id",
  "vmSize": "$POOL_VM_SIZE",
  "virtualMachineConfiguration": {
    "imageReference": {
      "publisher": "microsoft-dsvm",
      "offer": "ubuntu-hpc",
      "sku": "2004",
      "version": "latest"
    },
    "nodeAgentSKUId": "batch.node.ubuntu 20.04"
  },
  "targetLowPriorityNodes": $VM_NUMBER,
  "enableInterNodeCommunication": true,
  "InterComputeNodeCommunicationEnabled": true,
  "TaskSlotsPerNode": 1,
  "networkConfiguration": {
    "subnetId": "$compute_subnet_id"
  },
  "maxTasksPerNode": 1,
  "taskSchedulingPolicy": {
    "nodeFillType": "Pack"
  },
  "mountConfiguration": [
      {
          "nfsMountConfiguration": {
              "source": "$nfs_share_hostname:/${nfs_share_directory}",
              "relativeMountPath": "shared",
              "mountOptions": "-o rw,hard,rsize=65536,wsize=65536,vers=4,minorversion=1,tcp,sec=sys"
          }
      }
  ],
  "startTask": {
    "commandLine": "sudo bash -x /mnt/batch/tasks/fsmounts/shared/vm_scripts/initialize_system.sh",
    "userIdentity": {
      "autoUser": {
        "scope": "pool",
        "elevationLevel": "admin"
      }
    },
    "maxTaskRetryCount": 0,
    "waitForSuccess": true
  }
}
EOF

# Create a batch pool
az batch pool create --json-file ${pool_id}.json

# Look at the status of the batch pool
echo "az batch pool show --pool-id $pool_id --query \"state\""

# az batch pool show --pool-id $pool_id --query "state"

