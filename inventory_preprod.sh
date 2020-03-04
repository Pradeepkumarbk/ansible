#!/bin/bash
#login to portal


apt-get install jq -y

function print_azure_parameters {
cat<<EOF

Usage: $0  -u username -p password  -i tenantid -s subscription -r resourcegroup -v aksresoursegroup -d aksdevopspreprod

      -u pass the username/clientid
          -p pass the clientsecret/password
          -i pass the tenantid
          -s pass the subscription
          -r pass the rg

Examples:

    running the ansible file with parameters
    ./login.sh -u asdfsd -p asdfas -i asdfg -s asdfasdsdfasdfsddd -r rgname"
EOF

exit 1
}

while getopts "u:p:i:s:r:v:d:e:" opt; do
        case "$opt" in
                u)
                        clientid=$OPTARG
                        ;;
                p)
                        password=$OPTARG
                        ;;
                i)
                        tenantid=$OPTARG
                        ;;
                s)
                        subscription=$OPTARG
                        ;;
                r)
                        resourcegroup=$OPTARG
                        ;;
                v)
                        aksresoursegroup=$OPTARG
                        ;;
                d)
                        aksdevopspreprod=$OPTARG
                        ;;
                e)
                        env=$OPTARG
                        ;;
                *)
                        print_azure_parameters
                        ;;
        esac
done

[[ "$clientid" && "$password" && "$tenantid" && "$subscription" && "$resourcegroup" && "$aksresoursegroup" && "$aksdevopspreprod" ]] || print_azure_parameters

az account set --subscription ${subscription} 1> /dev/null

az login --service-principal --username $clientid --password $password --tenant $tenantid 1> /dev/null
echo ${aksdevopspreprod}
#To get ip address
aksdevopspreprodip=( $(az vm list-ip-addresses --resource-group  $aksdevopspreprod --query "[].{id:virtualMachine.network.privateIpAddresses[0]}" --output tsv) )
aksvmip=( $(az vm list-ip-addresses --resource-group  $aksresoursegroup --query "[].{id:virtualMachine.network.privateIpAddresses[0]}" --output tsv) )
tabip=( $(az vmss nic list -g $resourcegroup --vmss-name jll-am-tablea-rh-cluster --query [].{ip:ipConfigurations[0].privateIpAddress} -o tsv) )
nifiip=( $(az vmss nic list -g $resourcegroup --vmss-name jll-am-nifi-rh-instance --query [].{ip:ipConfigurations[0].privateIpAddress} -o tsv) )
j=0
echo [tableaumaster] > inventory

for i in "${tabip[@]}";
do
        echo $i
        echo $j
        j=$(( $j + 1 ))
        if [[ $j = 2 ]]; then
                echo -e "\n[tableauslave]" >> inventory
                echo $i ansible_ssh_user=pradeep ansible_sudo_pass=pradeep >> inventory;
                echo $i >> hosts;
        else
                echo $i ansible_ssh_user=pradeep ansible_sudo_pass=pradeep >> inventory;
                echo $i >> hosts;
        fi
done
j=0

echo -e "\n[nifi]" >> inventory

for i in "${nifiip[@]}";
do
     echo $i ansible_ssh_user=pradeep ansible_sudo_pass=pradeep
done >> inventory

for i in "${nifiip[@]}";
do
     echo $i
done >> hosts

echo -e "\n[vm]" >> inventory

for i in "${aksvmip[@]}";
do
        echo $i ansible_ssh_user=pradeep ansible_sudo_pass=pradeep
done >> inventory

for i in "${aksvmip[@]}";
do
        echo $i
done >> hosts

echo -e "\n[devopsvm]" >> inventory

for i in "${aksdevopspreprodip[@]}";
do
        echo $i ansible_ssh_user=pradeep ansible_sudo_pass=pradeep
done >> inventory

for i in "${aksdevopspreprodip[@]}";
do
        echo $i
done >> hosts


unset password
echo $password
