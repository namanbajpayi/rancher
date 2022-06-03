# <p align="center">**Rancher High Availability Setup On EKS**</p>
***
<p align="center">
  <img width="460" height="300" src="https://boxboat.com/2019/08/15/getting-started-with-rancher/featured.jpg">
</p>

---
* NOTE:
```
1. Please download all the files present here to your eks management server with same names.
2. Please add your ACM certificate ARN in rancher-controller.yaml (please comment this line if certificate is not required).
```

### <p align="center">**1. Install Ingress Controller**</p>
Ingress Controllers are required to access a Resource running on a Kubernetes Clusters, Although we have some services as well (NodePort/ClusterIP/LoadBalancer) for accessing a resource But Ingress comes under Best Practices.

`$ kubectl apply -f rancher-controller.yaml`

### <p align="center">**2. Install Rancher Using Helm**</p>
Helm is a package manager for kuberenetes. First we need to configure helm, After that we can easily install Rancher.

```Bash
1. $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
2. $ chmod 700 get_helm.sh
3. $ ./get_helm.sh
4. $ helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
5. $ helm repo update
6. $ helm install rancher rancher-stable/rancher --namespace cattle-system --set tls=external --set ingress.enabled=false   --set bootstrapPassword=mykaarmapassword
7. $ kubectl -n cattle-system rollout status deploy/rancher 
```
### <p align="center">**3. Configure Ingress**</p>
* Here we need to give our own Ingress file to create a Rule.

`$ kubectl apply -f rancher-rules.yaml`

* You want to Access **RANCHER** ? Here is the way.

`$ kubectl get ingress -n cattle-system`

### <p align="center">**4. Shifting Rancher Resources to dedicated Nodes**</p>
* Here we are shifting all resources associated with rancher to a specific Node Group
* Make sure to create a Node Group with this label `cluster: rancher`

```Bash
1. $ chmod +x nodechange.sh
2. $ ./nodechange.sh
```
# <p align="center">**Uninstalling Rancher**</p>
`$ helm uninstall rancher --namespace cattle-system`

### <p align="center">**Removing Complete Stack of Rancher**</p>
```Bash
1. $ helm uninstall rancher --namespace cattle-system
2. $ kubectl delete all --all -n cattle-system
3. $ kubectl delete ns <namespace-name> 
// delete all namespaces associated with rancher with above command, write all ns in above command and separate them with a space.
// namespaces are cattle-system,cattle-global-data,cattle-global-nt,fleet-*,local 
```
* If Namespaces are not deleting and going in `Terminating` state, apply following commands
```Bash
4. $ for ns in $(kubectl get ns --field-selector status.phase=Terminating -o jsonpath='{.items[*].metadata.name}'); do  kubectl get ns $ns -ojson | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -; done
5. $ for ns in $(kubectl get ns --field-selector status.phase=Terminating -o jsonpath='{.items[*].metadata.name}'); do  kubectl get ns $ns -ojson | jq '.metadata.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -; done
```
### <p align="center">**Troubleshooting**</p>

* Deleting CRDs
```Bash
1. $ kubectl get crds | grep cattle.io | awk 'FNR == 1 {next} { print "kubectl delete crd " $1 }' > crd.sh
2. $ sh crd.sh
3. $ for ns in $(kubectl get crds | grep cattle.io | awk '{print $1}'); do kubectl patch crd $ns -p '{"metadata":{"finalizers":[]}}' --type=merge; done
```
* Deleting Webhooks (if ERROR: Internal error occurred: failed calling webhook "rancher.cattle.io")
```Bash
1. $ kubectl delete validatingwebhookconfiguration rancher.cattle.io
2. $ kubectl delete mutatingwebhookconfiguration rancher.cattle.io
```

* Resotoring Admin User password (`0 users were found with authz.management.cattle.io/bootstrapping=admin-user label. They are []. Can only reset the default admin password when there is exactly one user with this label.`)
```Bash
$ kubectl --kubeconfig $KUBECONFIG -n cattle-system exec $(kubectl --kubeconfig $KUBECONFIG -n cattle-system get pods -l app=rancher | grep '1/1' | head -1 | awk '{ print $1 }') -- ensure-default-admin
```

### <p align="center">**Creating User in Rancher**</p>
* Click [here](https://docs.google.com/document/d/1amxWDqG2C5zjftnc1fvtMiNu2vfFU5SacYymtSNQIuc/edit#) to go to Rancher User Creation Doc.
