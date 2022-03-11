#!/bin/bash
#
# Die ersten vier Parameter sind vorgegeben durch die ResourcenGruppe in Azure
# 

# ID of your Azure subscription
export subscription_id=""
# Name of the resource group
export batch_rg=""
# Region
export region="westeurope"
# Unique batch account name (e.g. batchwsaccount3245353)
export batch_account_name=""
# Unique extension for the keyvault name (e.g. kv234)
# Maxc 24 Zeichen für  ${batch_account_name}${keyvault_extension} 
export keyvault_extension="kv18"


# Die restlichen Parameter sind Variabel, sollten aber einer
# gewissen Logik folgen.
# Die Parameter sind Beispiele, wie ich sie verwendet habe

# Unique storage account name (e.g. batchwastorage3245353)
export storage_account_name=""
# "batchwasest3245353"

# VNET name
export batch_vnet_name=""
# "batch-sest-vnet"

# Compute subnet name
export compute_subnet_name=""
# "compute"

# Unique storage account name for shared Azure Files NFS storage (e.g. batchwsnfsstorage3422435234)
export nfs_storage_account_name="" 
# "batchsestnfsa37"

# Name of tha Azure Files fileshare
export nfs_share="shared"

# Name des Pools
# ws2 for small machines
# ws3 for big machines
export pool_id="batch-ws2-pool"

# Wuerde ich hier definieren

# Public key for testing purposes
export ssh_pubkey="ssh-rsa AAAAB....."

# Type of the VM to be created
# For paths
#export VM_TYPE="HB120rsv2"
# For init-script
#export POOL_VM_SIZE="Standard_HB120rs_v2"

# For paths
export VM_TYPE="STANDARD_F2s"
# For init-script
export POOL_VM_SIZE="STANDARD_F2s_v2"


# Number of VMs to be created
export VM_NUMBER=2

