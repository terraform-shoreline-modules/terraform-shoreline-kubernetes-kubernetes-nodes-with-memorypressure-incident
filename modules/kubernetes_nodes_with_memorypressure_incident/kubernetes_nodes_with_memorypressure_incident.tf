resource "shoreline_notebook" "kubernetes_nodes_with_memorypressure_incident" {
  name       = "kubernetes_nodes_with_memorypressure_incident"
  data       = file("${path.module}/data/kubernetes_nodes_with_memorypressure_incident.json")
  depends_on = [shoreline_action.invoke_delete_apply_pods,shoreline_action.invoke_kubernetes_memory_usage,shoreline_action.invoke_memory_leak_detection]
}

resource "shoreline_file" "delete_apply_pods" {
  name             = "delete_apply_pods"
  input_file       = "${path.module}/data/delete_apply_pods.sh"
  md5              = filemd5("${path.module}/data/delete_apply_pods.sh")
  description      = "Delete and recreate the pod to see if that resolves the memory pressure issue"
  destination_path = "/agent/scripts/delete_apply_pods.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "kubernetes_memory_usage" {
  name             = "kubernetes_memory_usage"
  input_file       = "${path.module}/data/kubernetes_memory_usage.sh"
  md5              = filemd5("${path.module}/data/kubernetes_memory_usage.sh")
  description      = "The Kubernetes cluster may be under-provisioned, meaning that the resources allocated to the cluster are insufficient to handle the workload, leading to memory pressure."
  destination_path = "/agent/scripts/kubernetes_memory_usage.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "memory_leak_detection" {
  name             = "memory_leak_detection"
  input_file       = "${path.module}/data/memory_leak_detection.sh"
  md5              = filemd5("${path.module}/data/memory_leak_detection.sh")
  description      = "Identify and troubleshoot memory leaks in applications running on the node."
  destination_path = "/agent/scripts/memory_leak_detection.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_delete_apply_pods" {
  name        = "invoke_delete_apply_pods"
  description = "Delete and recreate the pod to see if that resolves the memory pressure issue"
  command     = "`chmod +x /agent/scripts/delete_apply_pods.sh && /agent/scripts/delete_apply_pods.sh`"
  params      = ["POD_MANIFEST_FILE","POD_NAME"]
  file_deps   = ["delete_apply_pods"]
  enabled     = true
  depends_on  = [shoreline_file.delete_apply_pods]
}

resource "shoreline_action" "invoke_kubernetes_memory_usage" {
  name        = "invoke_kubernetes_memory_usage"
  description = "The Kubernetes cluster may be under-provisioned, meaning that the resources allocated to the cluster are insufficient to handle the workload, leading to memory pressure."
  command     = "`chmod +x /agent/scripts/kubernetes_memory_usage.sh && /agent/scripts/kubernetes_memory_usage.sh`"
  params      = []
  file_deps   = ["kubernetes_memory_usage"]
  enabled     = true
  depends_on  = [shoreline_file.kubernetes_memory_usage]
}

resource "shoreline_action" "invoke_memory_leak_detection" {
  name        = "invoke_memory_leak_detection"
  description = "Identify and troubleshoot memory leaks in applications running on the node."
  command     = "`chmod +x /agent/scripts/memory_leak_detection.sh && /agent/scripts/memory_leak_detection.sh`"
  params      = ["POD_NAME","NAMESPACE"]
  file_deps   = ["memory_leak_detection"]
  enabled     = true
  depends_on  = [shoreline_file.memory_leak_detection]
}

