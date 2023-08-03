
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Nodes with Memorypressure incident
---

The Kubernetes Nodes with Memorypressure incident type occurs when a Kubernetes cluster node is running low on memory, which can be caused by a memory leak in an application. This incident type requires immediate attention to prevent any downtime and ensure the proper functioning of the Kubernetes cluster. Typically, this incident type is monitored by DevOps teams using various monitoring tools, including PagerDuty, to identify and address memory pressure issues quickly.

### Parameters
```shell
# Environment Variables

export NODE_NAME="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export POD_MANIFEST_FILE="PLACEHOLDER"

export MEMORY_SIZE="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export APPLICATION_NAME="PLACEHOLDER"
```

## Debug

### List all the nodes in the Kubernetes cluster
```shell
kubectl get nodes
```

### Get detailed information about a specific node
```shell
kubectl describe node ${NODE_NAME}
```

### Check the memory usage metrics for the node
```shell
kubectl top node ${NODE_NAME}
```

### List all the pods running on the node
```shell
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=${NODE_NAME}
```

### Get detailed information about a specific pod
```shell
kubectl describe pod ${POD_NAME}
```

### Check the memory usage metrics for the pod
```shell
kubectl top pod ${POD_NAME}
```

### Check the logs for the pod to see if there are any memory leak errors
```shell
kubectl logs ${POD_NAME}
```

### Check the Kubernetes events for the pod to see if there are any memory-related issues
```shell
kubectl get events --field-selector involvedObject.name=${POD_NAME}
```

### Delete and recreate the pod to see if that resolves the memory pressure issue
```shell
kubectl delete pod ${POD_NAME}

kubectl apply -f ${POD_MANIFEST_FILE}
```

### The Kubernetes cluster may be under-provisioned, meaning that the resources allocated to the cluster are insufficient to handle the workload, leading to memory pressure.
```shell
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

```

## Repair

### Identify and troubleshoot memory leaks in applications running on the node.
```shell
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
```