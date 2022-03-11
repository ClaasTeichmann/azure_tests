#!/bin/bash -x

az storage account create \
    --resource-group $batch_rg \
    --name $nfs_storage_account_name \
    --location $region \
    --kind FileStorage \
    --sku Premium_LRS \
    --allow-blob-public-access false \
    --default-action deny \
    --https-only false \
    --enable-large-file-share

storageAccountKey=$(az storage account keys list \
    --resource-group $batch_rg \
    --account-name $nfs_storage_account_name \
    --query "[0].value" | tr -d '"')

az storage account network-rule add \
    --resource-group $batch_rg \
    --account-name $nfs_storage_account_name \
    --vnet-name $batch_vnet_name \
    --subnet $compute_subnet_name

# Quota in GB
# Minimum is 100 GB
# Je kleiner, desto unperformanter
az storage share-rm create \
    --resource-group $batch_rg \
    --storage-account $nfs_storage_account_name \
    --name $nfs_share \
    --quota 1024 \
    --enabled-protocols NFS \
    --root-squash NoRootSquash

# Platte ist im Portal 
# Workgroup -> Storagename -> Dateifreigabe (links)
# Data storage -> File shares -> shared
# Da sieht man, wie man die Platte auf Linux z.b. mounten wuerde

## Mount under Ubuntu:

# sudo apt-get -y update
# sudo apt-get install nfs-common

# sudo mkdir -p /mount/batchctnfssa/shared
# sudo mount -t nfs batchctnfssa.file.core.windows.net:/batchctnfssa/shared /mount/batchctnfssa/shared -o vers=4,minorversion=1,sec=sys

# For testing purposes, the storage can be mounted via sshfs
