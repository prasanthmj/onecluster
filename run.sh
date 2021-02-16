#!/bin/bash



function initBase(){
   cd ./1-infra/mycluster/base
   terraform init
   
}

function deployBase(){
   cd ./1-infra/mycluster/base
   terraform apply -auto-approve
   IP=$(terraform show | egrep bastion_ip | cut -d'"' -f 2 )
   echo "IP is $IP"
   
}

function ProvisionBase(){
   cd ./1-infra/mycluster/base
   IP=$(terraform show | egrep bastion_ip | cut -d'"' -f 2 )
   echo "IP is $IP"
   cd ../../../2-provision/bastion 
   printf "$IP\n" > node.txt
   
   ANSIBLE_FORCE_COLOR=true 
   ansible-playbook bastion.yaml -i node.txt --user='root' --key-file="~/.ssh/tcloud" --ssh-extra-args='-p 22 -o ConnectTimeout=10 -o ConnectionAttempts=10 -o StrictHostKeyChecking=no' --extra-vars="deploy_user_name=nodeuser deploy_user_key_path=~/.ssh/mycluster-bastion.pub"
   
}

function destroyBase(){
   cd ./1-infra/mycluster/base
   terraform destroy -auto-approve
}


function initCluster(){
   NAME=$1
   cd "./1-infra/mycluster/$NAME"
   terraform init
}

function deployCluster(){
   NAME=$1
   cd "./1-infra/mycluster/$NAME"
   terraform apply -auto-approve
   
   NODES=$(terraform show | egrep ipv4_address | cut -d'"' -f 2 | sort -u)
   printf "$NODES\n"
   
}

function provisionCluster(){
   NAME=$1
   cd "./1-infra/mycluster/$NAME"
   NODES=$(terraform show | egrep ipv4_address | cut -d'"' -f 2 | sort -u)
   cd ../../../2-provision/cluster
   printf "$NODES\n" > cluster.txt
   ANSIBLE_FORCE_COLOR=true 
   
   ansible-playbook nodes.yaml -i cluster.txt --user='root' --key-file="~/.ssh/tcloud" --ssh-extra-args='-p 22 -o ConnectTimeout=10 -o ConnectionAttempts=10 -o StrictHostKeyChecking=no' --extra-vars="deploy_user_name=nodeuser deploy_user_key_path=~/.ssh/mycluster-nodes.pub"
   
}

function destroyCluster(){
   NAME=$1
   cd "./1-infra/mycluster/$NAME"
   terraform destroy -auto-approve
}


#Load environment variables
export $(egrep -v '^#' .env | xargs)

if [ -z "$1" ]
then
cat << USAGE
Usage:
Create a file .env in with environment variables.

./run.sh init base
    initializes terraform setup

./run.sh deploy base 
    creates the infrastructure
USAGE
      
      exit 1
fi

COMMAND=$1

WHAT=$2



case $WHAT in
   base)
      if [ "$COMMAND" == "init"   ]; then initBase; fi
      if [ "$COMMAND" == "deploy"   ]; then deployBase; fi
      if [ "$COMMAND" == "provision"   ]; then ProvisionBase; fi
      if [ "$COMMAND" == "destroy"   ]; then destroyBase; fi
   ;;
   prod)
      if [ "$COMMAND" == "init"   ]; then initCluster "prod"; fi
      if [ "$COMMAND" == "deploy"   ]; then deployCluster "prod"; fi
      if [ "$COMMAND" == "provision"   ]; then provisionCluster "prod"; fi
      if [ "$COMMAND" == "destroy"   ]; then destroyCluster "prod"; fi
   ;;   
esac