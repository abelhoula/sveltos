---
title: Viewing resources - Projectsveltos
description: Sveltos is an application designed to manage hundreds of clusters by providing declarative APIs to deploy Kubernetes add-ons across multiple clusters.
tags:
    - Kubernetes
    - add-ons
    - helm
    - clusterapi
    - multi-tenancy
    - Sveltos
    - Slack
authors:
    - Gianluca Mardente
---

While managing multiple clusters, it is important to have a central location for viewing a summary of resources in all To effectively manage multiple clusters, having a centralized location to view a summary of resources is crucial. Here are a few reasons why:

1. Centralized Visibility: A central location provides a unified view of resource summaries, allowing you to monitor and visualize the health of all your clusters in one place. This simplifies issue detection, trend identification, and problem troubleshooting across multiple clusters.
2. Efficient Troubleshooting and Issue Resolution: With a centralized resource view, you can swiftly identify the affected cluster when an issue arises, compare it with others, and narrow down potential causes. This comprehensive overview of resource states and dependencies enables efficient troubleshooting and quicker problem resolution.
3. Enhanced Security and Compliance: Centralized resource visibility strengthens security and compliance monitoring. It enables you to monitor cluster configurations, identify security vulnerabilities, and ensure consistent adherence to compliance standards across all clusters. You can easily track and manage access controls, network policies, and other security-related aspects from a single location.

Using Projectsveltos can facilitate the display of information about resources in managed clusters.

## Display deployments from managed clusters

To showcase information about deployments in each managed cluster, you can utilize a combination of a __ClusterHealthCheck__ and a __HealthCheck__. Here's how you can achieve this:

1. Create a HealthCheck instance that contains a Lua script responsible for examining all deployments in the managed cluster. In the example below, deployments with a difference between the number of available replicas and requested replicas are identified as degraded:
```yaml
apiVersion: lib.projectsveltos.io/v1alpha1
kind: HealthCheck
metadata:
 name: deployment-replicas
spec:
 collectResources: true
 group: "apps"
 version: v1
 kind: Deployment
 script: |
   function evaluate()
     hs = {}
     hs.status = "Progressing"
     hs.message = ""
     if obj.spec.replicas == 0 then
       hs.ignore=true
       return hs
     end
     if obj.status ~= nil then
       if obj.status.availableReplicas ~= nil then
         if obj.status.availableReplicas == obj.spec.replicas then
           hs.status = "Healthy"
           hs.message = "All replicas " .. obj.spec.replicas .. " are healthy"
         else
           hs.status = "Progressing"
           hs.message = "expected replicas: " .. obj.spec.replicas .. " available: " .. obj.status.availableReplicas
         end
       end
       if obj.status.unavailableReplicas ~= nil then
          hs.status = "Degraded"
          hs.message = "deployments have unavailable replicas"
       end
     end
     return hs
   end
```
 
 2. use the ClusterHealthCheck and set the clusterSelector field to filter which managed clusters' deployments should be examined. In the following example, all managed clusters that match the cluster label selector env=fv are considered:
```yaml
apiVersion: lib.projectsveltos.io/v1alpha1
kind: ClusterHealthCheck
metadata:
  name: production
spec:
  clusterSelector: env=fv
  livenessChecks:
  - name: deployment
    type: HealthCheck
    livenessSourceRef:
      kind: HealthCheck
      apiVersion: lib.projectsveltos.io/v1alpha1
      name: deployment-replicas
  notifications:
  - name: event
    type: KubernetesEvent

```

By following these steps, you can create a HealthCheck instance with a Lua script to evaluate deployments in a managed cluster and a ClusterHealthCheck instance to filter the clusters that should be examined based on their labels. This approach enables you to display information about deployments across specific managed clusters effectively.

To obtain a consolidated view of resource information, __sveltosctl show resources__ command can be used. Here's an example of the command output:

```bash
kubectl exec -it -n projectsveltos sveltosctl-0 -- ./sveltosctl show resources --kind=deployment 
+-----------------------------+--------------------------+----------------+-----------------------------------------+----------------------------+
|           CLUSTER           |           GVK            |   NAMESPACE    |                  NAME                   |          MESSAGE           |
+-----------------------------+--------------------------+----------------+-----------------------------------------+----------------------------+
| default/clusterapi-workload | apps/v1, Kind=Deployment | kube-system    | calico-kube-controllers                 | All replicas 1 are healthy |
|                             |                          | kube-system    | coredns                                 | All replicas 2 are healthy |
|                             |                          | kyverno        | kyverno-admission-controller            | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-background-controller           | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-cleanup-controller              | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-reports-controller              | All replicas 1 are healthy |
|                             |                          | projectsveltos | sveltos-agent-manager                   | All replicas 1 are healthy |
| gke/pre-production          |                          | gke-gmp-system | gmp-operator                            | All replicas 1 are healthy |
|                             |                          | gke-gmp-system | rule-evaluator                          | All replicas 1 are healthy |
|                             |                          | kube-system    | antrea-controller-horizontal-autoscaler | All replicas 1 are healthy |
|                             |                          | kube-system    | egress-nat-controller                   | All replicas 1 are healthy |
|                             |                          | kube-system    | event-exporter-gke                      | All replicas 1 are healthy |
|                             |                          | kube-system    | konnectivity-agent                      | All replicas 4 are healthy |
|                             |                          | kube-system    | konnectivity-agent-autoscaler           | All replicas 1 are healthy |
|                             |                          | kube-system    | kube-dns                                | All replicas 2 are healthy |
|                             |                          | kube-system    | kube-dns-autoscaler                     | All replicas 1 are healthy |
|                             |                          | kube-system    | l7-default-backend                      | All replicas 1 are healthy |
|                             |                          | kube-system    | metrics-server-v0.5.2                   | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-admission-controller            | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-background-controller           | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-cleanup-controller              | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-reports-controller              | All replicas 1 are healthy |
|                             |                          | nginx          | nginx-deployment                        | All replicas 2 are healthy |
|                             |                          | projectsveltos | sveltos-agent-manager                   | All replicas 1 are healthy |
| gke/production              |                          | gke-gmp-system | gmp-operator                            | All replicas 1 are healthy |
|                             |                          | gke-gmp-system | rule-evaluator                          | All replicas 1 are healthy |
|                             |                          | kube-system    | antrea-controller-horizontal-autoscaler | All replicas 1 are healthy |
|                             |                          | kube-system    | egress-nat-controller                   | All replicas 1 are healthy |
|                             |                          | kube-system    | event-exporter-gke                      | All replicas 1 are healthy |
|                             |                          | kube-system    | konnectivity-agent                      | All replicas 3 are healthy |
|                             |                          | kube-system    | konnectivity-agent-autoscaler           | All replicas 1 are healthy |
|                             |                          | kube-system    | kube-dns                                | All replicas 2 are healthy |
|                             |                          | kube-system    | kube-dns-autoscaler                     | All replicas 1 are healthy |
|                             |                          | kube-system    | l7-default-backend                      | All replicas 1 are healthy |
|                             |                          | kube-system    | metrics-server-v0.5.2                   | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-admission-controller            | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-background-controller           | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-cleanup-controller              | All replicas 1 are healthy |
|                             |                          | kyverno        | kyverno-reports-controller              | All replicas 1 are healthy |
|                             |                          | projectsveltos | sveltos-agent-manager                   | All replicas 1 are healthy |
+-----------------------------+--------------------------+----------------+-----------------------------------------+----------------------------+
```

Here are the available options to filter what show resources will display:

```bash
--group=<group>: Show Kubernetes resources deployed in clusters matching this group. If not specified, all groups are considered.
--kind=<kind>: Show Kubernetes resources deployed in clusters matching this Kind. If not specified, all kinds are considered.
--namespace=<namespace>: Show Kubernetes resources in this namespace. If not specified, all namespaces are considered.
--cluster-namespace=<name>: Show Kubernetes resources in clusters in this namespace. If not specified, all namespaces are considered.
--cluster=<name>: Show Kubernetes resources in the cluster with the specified name. If not specified, all cluster names are considered.
```

Additionally, using the __--full option__, you can display the complete details of the resources:

```bash
kubectl exec -it -n projectsveltos sveltosctl-0 -- ./sveltosctl show resources --full
Cluster:  default/clusterapi-workload
Object:  object:
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    annotations:
      deployment.kubernetes.io/revision: "1"
    creationTimestamp: "2023-07-11T14:03:15Z"
    ...
``` 

## Display Kyverno PolicyReports

In this example we will define an HealthCheck containing a Lua script that will:

1. examine all Kyverno PolicyReports;
2. will report all resources in violation of the policy and rule. 

```yaml
apiVersion: lib.projectsveltos.io/v1alpha1
kind: HealthCheck
metadata:
 name: deployment-replicas
spec:
 collectResources: true
 group: "apps"
 version: v1
 kind: Deployment
 script: |
   function evaluate()
     hs = {}
     hs.status = "Healthy"
     hs.message = ""
     for i, result in ipairs(obj.results) do
       if result.result == "fail" then
          hs.status = "Degraded"
          for j, r in ipairs(result.resources) do
             hs.message = hs.message .. " " .. r.namespace .. "/" .. r.name
          end
       end
     end
     if hs.status == "Healthy" then
       hs.ignore = true
     end
     return hs
   end
```

As before, we also need to have a ClusterHealthCheck instance to instruct Sveltos which clusters to watch.

```yaml
apiVersion: lib.projectsveltos.io/v1alpha1
kind: ClusterHealthCheck
metadata:
  name: production
spec:
  clusterSelector: env=fv
  livenessChecks:
  - name: kyverno-policy-reports
    type: HealthCheck
    livenessSourceRef:
      kind: HealthCheck
      apiVersion: lib.projectsveltos.io/v1alpha1
      name: kyverno-policy-reports
  notifications:
  - name: event
    type: KubernetesEvent
```

assuming we have deployed an nginx deployment using __latest__ in one of our managed cluster[^1]

```bash
ubectl exec -it -n projectsveltos sveltosctl-0 -- ./sveltosctl show resources  
+-------------------------------------+--------------------------------+-----------+--------------------------+-----------------------------------------+
|               CLUSTER               |              GVK               | NAMESPACE |           NAME           |                 MESSAGE                 |
+-------------------------------------+--------------------------------+-----------+--------------------------+-----------------------------------------+
| default/sveltos-management-workload | wgpolicyk8s.io/v1alpha2,       | nginx     | cpol-disallow-latest-tag |  nginx/nginx-deployment                 |
|                                     | Kind=PolicyReport              |           |                          | nginx/nginx-deployment-6b7f675859       |
|                                     |                                |           |                          | nginx/nginx-deployment-6b7f675859-fp6tm |
|                                     |                                |           |                          | nginx/nginx-deployment-6b7f675859-kkft8 |
+-------------------------------------+--------------------------------+-----------+--------------------------+-----------------------------------------+
```

[^1]:
To deploy Kyverno and a ClusterPolicy in each managed cluster matching label selector __env=fv__ we can use this ClusterProfile
```yaml
  apiVersion: config.projectsveltos.io/v1alpha1
  kind: ClusterProfile
  metadata:
    name: kyverno
  spec:
    clusterSelector: env=fv
    helmCharts:
    - chartName: kyverno/kyverno
      chartVersion: v3.0.1
      helmChartAction: Install
      releaseName: kyverno-latest
      releaseNamespace: kyverno
      repositoryName: kyverno
      repositoryURL: https://kyverno.github.io/kyverno/
    policyRefs:
    - deploymentType: Remote
      kind: ConfigMap
      name: kyverno-latest
      namespace: default
```
where ConfigMap contains [this](https://kyverno.io/policies/best-practices/disallow-latest-tag/disallow-latest-tag/) Kyverno ClusterPolicy
```bash
wget https://github.com/kyverno/policies/raw/main//best-practices/disallow-latest-tag/disallow-latest-tag.yaml
kubectl create configmap kyverno-latest --from-file disallow-latest-tag.yaml
```