#!/bin/bash

# Create Resource Group and it set as default
az group create -l westeurope -n RADIUSCentOS
az configure --defaults location=westeurope group=RADIUSCentOS

# Create infrastructure's LAN
az network vnet create \
    --resource-group RADIUSCentOS \
    --name CentOS_Vnet \
    --address-prefix 192.168.0.0/16 \
    --subnet-name CentOS_Subnet \
    --subnet-prefix 192.168.1.0/24

# Create public ips to infrastrutture's access from Internet
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-01-Public-IP \
    --dns-name cts-radius-01
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-02-Public-IP \
    --dns-name cts-radius-02

# Create Network Security Groups and policy for infrastrutture's access
az network nsg create \
    --resource-group RADIUSCentOS \
    --name CentOS_NSG
az network nsg rule create \
    --resource-group RADIUSCentOS \
    --nsg-name CentOS_NSG \
    --name CentOS_NSG_SSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

# Create vNics for VM networking
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-01-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-01-Public-IP \
    --network-security-group CentOS_NSG
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-02-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-02-Public-IP \
    --network-security-group CentOS_NSG

# Availabilities set for redundancy
az vm availability-set create \
    --resource-group RADIUSCentOS \
    --name CentOS_AS

# Create VMs and connect to infrastructure's networking
export MYACCESSPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRKiDx4MT6/rg2kHf5K+dATbmW+cX3BAjvBS33TpbcZW7nDh7wOHi/rZUrmWV/55+MZFALmlPYQolJwZZfQarswwIsYaBEeeLWVbOfVbW0/43AjioGyNJ7CKrxn86rlqKLSevgwJGDAheP5OM15UCsNHTVQEOVNRcLIRduJitvk0su2X34ugyb2VxDwf6bSg3PQx0xHkMaqwzEgvpR21RL/ywnsCiDihXMuvBiF90/LHQX1aJXL91tOFarFFdkgozIM0lgF4AuKz/K261lxMFRTXJsXgWTpTXv1Oriudp+FU4RXVIOppd9/4gvZu6KKAGcxFUUP2VqGf+69+BVgMSqzgLote1cpQ7jc+2SghkqnOdjSfaiLBw5L8V7wKqbzq4qWDEp/bhoNVBoKtzlV4/6JvzVRGrf10cGSsD96duBGy+vbeUWrLzHqcY5HNAEM3xVj51QN181IKuYGkTodcPwlt0itQmSNa+QdzAsUEi1UxtMDVQzaeGoxtDmY60yzS8Uy7sgUjF0GRt8rSVMrdcs2pPBbrNkUvYMopFq5AjpLUo0W/wdv20kL5XqYjh419/YH8+yVzis6Vu+H6FnKhBcJWpvbyNf+b0EEPuk0BSErDZiC45hcT87zEgYIGr2NWKVuRfw6RhKzQf5DJvUsGn2V4YDsRdF1AFTYvR2L0gYJQ== latin@LAPTOP-07ATIDEC'
echo $MYACCESSPUBKEY > ~/.ssh/myaccesskey.pub
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius01 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-01-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius02 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-02-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub

export MYACCESSPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRKiDx4MT6/rg2kHf5K+dATbmW+cX3BAjvBS33TpbcZW7nDh7wOHi/rZUrmWV/55+MZFALmlPYQolJwZZfQarswwIsYaBEeeLWVbOfVbW0/43AjioGyNJ7CKrxn86rlqKLSevgwJGDAheP5OM15UCsNHTVQEOVNRcLIRduJitvk0su2X34ugyb2VxDwf6bSg3PQx0xHkMaqwzEgvpR21RL/ywnsCiDihXMuvBiF90/LHQX1aJXL91tOFarFFdkgozIM0lgF4AuKz/K261lxMFRTXJsXgWTpTXv1Oriudp+FU4RXVIOppd9/4gvZu6KKAGcxFUUP2VqGf+69+BVgMSqzgLote1cpQ7jc+2SghkqnOdjSfaiLBw5L8V7wKqbzq4qWDEp/bhoNVBoKtzlV4/6JvzVRGrf10cGSsD96duBGy+vbeUWrLzHqcY5HNAEM3xVj51QN181IKuYGkTodcPwlt0itQmSNa+QdzAsUEi1UxtMDVQzaeGoxtDmY60yzS8Uy7sgUjF0GRt8rSVMrdcs2pPBbrNkUvYMopFq5AjpLUo0W/wdv20kL5XqYjh419/YH8+yVzis6Vu+H6FnKhBcJWpvbyNf+b0EEPuk0BSErDZiC45hcT87zEgYIGr2NWKVuRfw6RhKzQf5DJvUsGn2V4YDsRdF1AFTYvR2L0gYJQ== latin@LAPTOP-07ATIDEC'
echo $MYACCESSPUBKEY > ~/.ssh/myaccesskey.pub
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-03-Public-IP \
    --dns-name cts-radius-03
az network nsg rule create \
    --resource-group RADIUSCentOS \
    --nsg-name CentOS_NSG \
    --name CentOS_NSG_SSH \
    --protocol tcp \
    --priority 1010 \
    --destination-port-range 443 \
    --access allow
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-03-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-03-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius03 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-03-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub


export MYACCESSPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRKiDx4MT6/rg2kHf5K+dATbmW+cX3BAjvBS33TpbcZW7nDh7wOHi/rZUrmWV/55+MZFALmlPYQolJwZZfQarswwIsYaBEeeLWVbOfVbW0/43AjioGyNJ7CKrxn86rlqKLSevgwJGDAheP5OM15UCsNHTVQEOVNRcLIRduJitvk0su2X34ugyb2VxDwf6bSg3PQx0xHkMaqwzEgvpR21RL/ywnsCiDihXMuvBiF90/LHQX1aJXL91tOFarFFdkgozIM0lgF4AuKz/K261lxMFRTXJsXgWTpTXv1Oriudp+FU4RXVIOppd9/4gvZu6KKAGcxFUUP2VqGf+69+BVgMSqzgLote1cpQ7jc+2SghkqnOdjSfaiLBw5L8V7wKqbzq4qWDEp/bhoNVBoKtzlV4/6JvzVRGrf10cGSsD96duBGy+vbeUWrLzHqcY5HNAEM3xVj51QN181IKuYGkTodcPwlt0itQmSNa+QdzAsUEi1UxtMDVQzaeGoxtDmY60yzS8Uy7sgUjF0GRt8rSVMrdcs2pPBbrNkUvYMopFq5AjpLUo0W/wdv20kL5XqYjh419/YH8+yVzis6Vu+H6FnKhBcJWpvbyNf+b0EEPuk0BSErDZiC45hcT87zEgYIGr2NWKVuRfw6RhKzQf5DJvUsGn2V4YDsRdF1AFTYvR2L0gYJQ== latin@LAPTOP-07ATIDEC'
echo $MYACCESSPUBKEY > ~/.ssh/myaccesskey.pub
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-04-Public-IP \
    --dns-name cts-radius-04
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-04-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-04-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius04 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-04-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-05-Public-IP \
    --dns-name cts-radius-05
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-05-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-05-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius05 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-05-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub  
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-06-Public-IP \
    --dns-name cts-radius-06
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-06-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-06-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius06 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-06-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub    

export MYACCESSPUBKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRKiDx4MT6/rg2kHf5K+dATbmW+cX3BAjvBS33TpbcZW7nDh7wOHi/rZUrmWV/55+MZFALmlPYQolJwZZfQarswwIsYaBEeeLWVbOfVbW0/43AjioGyNJ7CKrxn86rlqKLSevgwJGDAheP5OM15UCsNHTVQEOVNRcLIRduJitvk0su2X34ugyb2VxDwf6bSg3PQx0xHkMaqwzEgvpR21RL/ywnsCiDihXMuvBiF90/LHQX1aJXL91tOFarFFdkgozIM0lgF4AuKz/K261lxMFRTXJsXgWTpTXv1Oriudp+FU4RXVIOppd9/4gvZu6KKAGcxFUUP2VqGf+69+BVgMSqzgLote1cpQ7jc+2SghkqnOdjSfaiLBw5L8V7wKqbzq4qWDEp/bhoNVBoKtzlV4/6JvzVRGrf10cGSsD96duBGy+vbeUWrLzHqcY5HNAEM3xVj51QN181IKuYGkTodcPwlt0itQmSNa+QdzAsUEi1UxtMDVQzaeGoxtDmY60yzS8Uy7sgUjF0GRt8rSVMrdcs2pPBbrNkUvYMopFq5AjpLUo0W/wdv20kL5XqYjh419/YH8+yVzis6Vu+H6FnKhBcJWpvbyNf+b0EEPuk0BSErDZiC45hcT87zEgYIGr2NWKVuRfw6RhKzQf5DJvUsGn2V4YDsRdF1AFTYvR2L0gYJQ== latin@LAPTOP-07ATIDEC'
echo $MYACCESSPUBKEY > ~/.ssh/myaccesskey.pub
az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-07-Public-IP \
    --dns-name cts-radius-07
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-07-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-07-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius07 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-07-NIC-01 \
    --image CentOS \
    --admin-username sysop \
    --ssh-key-values ~/.ssh/myaccesskey.pub

az network public-ip create \
    --resource-group RADIUSCentOS \
    --name cts-radius-08-Public-IP \
    --dns-name cts-radius-08
az network nic create \
    --resource-group RADIUSCentOS \
    --name cts-radius-08-NIC-01 \
    --vnet-name CentOS_Vnet \
    --subnet CentOS_Subnet \
    --public-ip-address cts-radius-08-Public-IP \
    --network-security-group CentOS_NSG
az vm create \
    --resource-group RADIUSCentOS \
    --name ctsRadius08 \
    --location westeurope \
    --availability-set CentOS_AS \
    --nics cts-radius-08-NIC-01 \
    --image Win2016Datacenter \
    --admin-username sysop \
    --admin-password PippoBaudo123
az network nsg rule create \
    --resource-group RADIUSCentOS \
    --nsg-name CentOS_NSG \
    --name WS_NSG_RDP \
    --protocol tcp \
    --priority 1020 \
    --destination-port-range 3389 \
    --access allow
    