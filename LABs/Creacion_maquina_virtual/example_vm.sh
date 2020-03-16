#!/bin/bash
################################################
#
#   Script sencillo para crear un VM en azure
#
################################################

##---- Variables ----##

LOCATION=northeurope        # Location where you want to deploy the VM
RESOURCE_NAME=LAB_vthot4    # Name of Resource Group.
VM_NAME=UbuntuLAB           # Name of VM
VM_IMAGE=UbuntuLTS          # Image you want to use for VM.
VM_USER=vteteam             # User to connect to the VM

help(){
    echo "$0 Usage:"
	echo " "
	echo " create       Create a VM "
    echo " connect      Connect to the VM"
    echo " webservice   Install nginx server"
	echo " delete       Delete VM "
	echo " "
}

create_Resource(){
	az group create --name $RESOURCE_NAME --location $LOCATION
	sleep 2
}

get_IP(){
    IP_VM=$(az vm show -d -g $RESOURCE_NAME -n $VM_NAME --query "publicIps" -o tsv)
}

case $1 in 
	create)
		echo " Creating resource ....$RESOURCE_NAME"
		create_Resource

		echo " Creating VM ..... $VM_NAME with image: $VM_IMAGE"
		az vm create --resource-group $RESOURCE_NAME --name $VM_NAME --image $VM_IMAGE --admin-username $VM_USER
		;;
    
    connect)
        echo " Conecting ...."
        ## Get VM's public IP
        get_IP
        echo $IP_VM
        ssh $VM_USER@"$IP_VM"
        ;;
    
    webservice)
        echo " Install nginx service ......"
        get_IP
        ssh $VM_USER@"$IP_VM" sudo apt-get -y update
        ssh $VM_USER@"$IP_VM" sudo apt-get -y install nginx
        
        echo " "
        echo "Abriendo puertos ...."
        az vm open-port --port 80 --resource-group $RESOURCE_NAME --name $VM_NAME
        ;;

    all)
        echo " Creating resource ....$RESOURCE_NAME"
		create_Resource

		echo " Creating VM ..... $VM_NAME with image: $VM_IMAGE"
		az vm create --resource-group $RESOURCE_NAME --name $VM_NAME --image $VM_IMAGE --admin-username $VM_USER
		echo " Install nginx service ......"
        get_IP
        ssh $VM_USER@"$IP_VM" sudo apt-get -y update
        ssh $VM_USER@"$IP_VM" sudo apt-get -y install nginx
        
        echo " "
        echo "Abriendo puertos ...."
        az vm open-port --port 80 --resource-group $RESOURCE_NAME --name $VM_NAME
        echo ""
        echo "http://$IP_VM/"
        ;;

    ip)
        get_IP
        echo "$IP_VM"
        ;;

	delete)
		echo " Deleting VM and resource group ........ "
		az group delete --name $RESOURCE_NAME
		;;

	*)
		help
		;;
esac


