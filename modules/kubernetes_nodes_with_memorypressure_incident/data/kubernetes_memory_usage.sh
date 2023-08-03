#!/bin/bash

# Get the percentage of memory used on each node in the Kubernetes cluster

NODES=($(kubectl get nodes --no-headers | awk '{print $1}'))

for NODE in "${NODES[@]}"

do

  MEMORY_PERCENTAGE=$(kubectl describe node $NODE | grep -i "memory pressure" | awk '{print $3}' | sed 's/(//g' | sed 's/)//g')

  echo "Node $NODE is using ${MEMORY_PERCENTAGE}% of memory"

done

# Get the total amount of memory available in the Kubernetes cluster

MEMORY_CAPACITY=$(kubectl describe nodes | grep -i "memory capacity" | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' | awk '{s+=$1} END {print s/1024/1024 " GB"}')

echo "The Kubernetes cluster has a total memory capacity of $MEMORY_CAPACITY"

# Calculate the total amount of memory used in the Kubernetes cluster

MEMORY_USED=$(kubectl describe nodes | grep -i "memory capacity" | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' | awk '{s+=$1} END {print s}')

echo "The Kubernetes cluster is currently using $(($MEMORY_USED/1024/1024)) GB of memory"

# Calculate the percentage of memory used in the Kubernetes cluster

MEMORY_PERCENTAGE=$(($MEMORY_USED*100/$MEMORY_CAPACITY))

echo "The Kubernetes cluster is using ${MEMORY_PERCENTAGE}% of memory capacity"

# Check if the memory usage is close to the memory capacity

THRESHOLD=90

if [ $MEMORY_PERCENTAGE -ge $THRESHOLD ]

then
  echo "The Kubernetes cluster may be under-provisioned, as the memory usage is above ${THRESHOLD}% threshold"

else

  echo "The Kubernetes cluster memory usage is within normal range"

fi