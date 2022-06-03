export PATH=/root/.local/bin:/opt/maven/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/bin
#!/bin/bash

rancherdeploy=("cattle-system-ingress-controller" "rancher" "rancher-webhook")
fleetdeploy=("fleet-agent" "fleet-controller" "gitjob")
rancheroperator=("rancher-operator")

for deploy in "${rancherdeploy[@]}"
do
        kubectl patch deployment ${deploy} -n cattle-system --patch "$(cat patch.yaml)"
done
for deploy in "${fleetdeploy[@]}"
do
        kubectl patch deployment ${deploy} -n fleet-system --patch "$(cat patch.yaml)"
done
for deploy in "${rancheroperator[@]}"
do
        kubectl patch deployment ${deploy} -n rancher-operator-system --patch "$(cat patch.yaml)"
done
