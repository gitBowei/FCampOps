az group create --name AKSLabRG --location eastus2
az aks create -g AKSLabRG -n AKS14nov19 --node-vm-size Standard_DS2_v2 --node-count 1 --location eastus2 --disable-rbac --generate-ssh-keys

az aks use-dev-spaces -g AKSLabRG -n AKS14nov19

git clone https://github.com/Azure/dev-spaces

