#!/bin/bash -x

# Variables
source variables.sh

az batch pool delete --pool-id ${pool_id}
