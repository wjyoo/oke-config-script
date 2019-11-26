#!/bin/bash 

userid=${2}
user_ocid=${3}
tenancy_ocid=${4}
tenancy_namespace=""
auth_token=""
region="ap-seoul-1"
docker_server="icn.ocir.io"


function main() {

  if [ -e "$HOME/.kube/out" ]
  then
    $(rm -rf $HOME/.kube/out)
  fi 

    $(mkdir $HOME/.kube/out)
    $(touch $HOME/.kube/out/jobs.out)
  
  tenancy_namespace=$(oci os ns get | jq '.data' | sed 's/"//g')
  echo "tenancy_namespace:" $tenancy_namespace >> $HOME/.kube/out/jobs.out
  echo "user_ocid:" $user_ocid >> $HOME/.kube/out/jobs.out
  echo "tenancy_ocid:" $tenancy_ocid >> $HOME/.kube/out/jobs.out

  #oci os ns get | jq '.data' | sed 's/"//g' >> $HOME/.kube/out/jobs.out

  userno=${USER:4}
  if [ $userno -ge 233 ]
  then
	region="ap-tokyo-1"
 	docker_server="nrt.ocir.io"     
  fi 

  create_kubeconfig
  create_kubernetes_secret_for_OCIR
  git_config_setup
  make_kubeproxy_alias
}

function create_kubeconfig(){
  compartment_id=$(oci iam compartment list --all --query "data [?\"name\" == 'MCD'].{id:id}" |awk '{print $2}'| sed 's/"//g')
  cluster_id=$(oci ce cluster list --compartment-id $compartment_id --region $region --lifecycle-state "ACTIVE" --query "data[*].{id:id}" |awk '{print $2}'| sed 's/"//g')
echo "compart_id=" $compartment_id
echo "cluster_id=" $cluster_id
echo "region=" $region
  result=$(oci ce cluster create-kubeconfig --cluster-id $cluster_id --file $HOME/.kube/config --region $region --token-version 1.0.0)
  echo $result
echo "config file created"

  echo "compartment_id: " $compartment_id >> $HOME/.kube/out/jobs.out
  echo "kubecluster_id: " $cluster_id >> $HOME/.kube/out/jobs.out
  echo "kubernetes cluster info was writted to config." >> $HOME/.kube/out/jobs.out

  echo "export KUBECONFIG=$HOME/.kube/config" >> $HOME/.bash_profile
}

function create_kubernetes_secret_for_OCIR(){
  auth_value=$(<auth_token)

  echo "auth_token" $auth_value>> $HOME/.kube/out/jobs.out
  kubectl delete secret ocirsecret --namespace=default
  kubectl create secret docker-registry ocirsecret --docker-server=$docker_server --docker-email=$userid --docker-username=$tenancy_namespace/$userid --docker-password="$auth_value" --namespace=default
  
}

function git_config_setup(){
  rm -rf .git
  mkdir .git
  git config --global user.name $USER
  git config --global user.email $userid
  git config credential.helper store
  git config credential.helper cache
  git config --global credential.helper 'cache --timeout 172800'
}

function make_kubeproxy_alias(){
	
	proxyport=8${USER:4}
	echo "alias kubeproxy='kubectl proxy --port $proxyport'" >> $HOME/.bash_profile
}
main
