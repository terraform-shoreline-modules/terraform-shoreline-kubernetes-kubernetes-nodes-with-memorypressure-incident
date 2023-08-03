#!/bin/bash

# Set the namespace and pod name

NAMESPACE=${NAMESPACE}

POD=${POD_NAME}

# Get the name of the container running on the pod

CONTAINER=$(kubectl -n $NAMESPACE get po $POD -o jsonpath='{.spec.containers[0].name}')

# Get the logs for the container

LOGS=$(kubectl -n $NAMESPACE logs $POD $CONTAINER)

# Search the logs for any indications of a memory leak

if echo "$LOGS" | grep -q "memory leak"; then

    # If a memory leak is detected, identify the application causing the leak

    APPLICATION=$(echo "$LOGS" | grep "memory leak" | awk '{print $NF}')

    # Stop the container running the problematic application

    kubectl -n $NAMESPACE delete po $POD --grace-period=0 --force

    echo "Stopped container $CONTAINER running $APPLICATION due to memory leak"

else

    echo "No memory leaks detected in container $CONTAINER"

fi