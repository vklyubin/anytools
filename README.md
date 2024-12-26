# Anytools image
Anytools image contains number of networking troubleshooting tools including 
QUAGGA tools allowing to setup router with BGP peering capabilites.
Anytools image can be used either in Docker/Containerd scanario or as image in Kubernetes cluster

## Pre-requisites
1. Image uploaded in Image repository or available in CRI cache
2. Runtime environemt permit executing container with cpabilities in Security Context [ "NET_RAW", "NET_ADMIN", "SYS_ADMIN"]

## Usage
1. Upload container in Repository or directly into CRI cache
2. In TKG/k8s install multus and create Network Attchement Definition 
2. Run container:
  a. in Docker/Containerd environement
  b. TKG as pod or deployment
  c. In Helm as NGINX replacement (Telco Cloud Automation)
3. Execute into container with /bin/bash
4. Follow IP tool manaul to configure subinterfaces or asssign IPs and Quagga tool guide to configure BGP router

### IP tool;
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-configure_802_1q_vlan_tagging_using_the_command_line

### FRR (vtysh)
https://docs.frrouting.org/en/stable-10.2/

## Examples:
  ### Network Attchement Definition
```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: trunk-macvlan
spec:
  config: '{ "cniVersion": "0.4.0", 
              "name": "trunk-macvlan-MULTUS", 
              "plugins":
              [ 
                { 
                  "type": "macvlan",
                  "master": "test-trunk",
                  "mode": "private" 
                }, 
                {
                  "type": "tuning",
                  "sysctl": { 
                      "net.ipv4.conf.net0.proxy_arp": "0" 
                  } 
                } 
              ]
            }'
```

  ### Pod
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    pod: anytools-quagga
  name: anytools-quagga
  
  namespace: anytools
  annotations:
    k8s.v1.cni.cncf.io/networks: default/trunk-macvlan@net0
spec:
  containers:
  - image: harbor.nest.pso.vmware.com:443/tcp-caas/anytools:1.6
    imagePullPolicy: IfNotPresent
    name: anytools-quagga

    securityContext:
      capabilities:
        add:
        - NET_RAW
        - NET_ADMIN
        - SYS_ADMIN
```

  ## Deployment
```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: anytools-quagga
  name: anytools-quagga

spec:
  replicas: 1
  selector:
    matchLabels:
      app: anytools-quagga

  template:
    metadata:
      labels:
        app: anytools-quagga
      annotations:
        k8s.v1.cni.cncf.io/networks: trunk-macvlan@net0
    spec:
      containers:
      - image: harbor.nest.pso.vmware.com:443/tcp-caas/anytools:1.5
        imagePullPolicy: IfNotPresent
        name: anytools-quagga

        securityContext:

          capabilities:
            add:
            - NET_RAW
            - NET_ADMIN
            - SYS_ADMIN
```

  ## TCA value file as NGINX image replacement (limitations: not possible to create VLAN sub interface nor use BGP)
```
image:
  registry: harbor.vkl.vmware.com:443
  repository: tcp-caas/anytools
  tag: 1.5
  pullPolicy: IfNotPresent

replicaCount: 2

podAnnotations:
  k8s.v1.cni.cncf.io/networks: vlan-whereabouts-vlan124

podAntiAffinityPreset: hard

service:
  annotations:
    aviinfrasetting.ako.vmware.com/name: aviinfra-vip-107
    
  externalTrafficPolicy: Cluster
  port: 80
  httpsPort: 443

  type: LoadBalancer
  loadBalancerIP: "192.168.107.131"
```

