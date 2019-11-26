#!/bin/bash 

userid=${2}
user_ocid=${3}
tenancy_ocid=${4}
tenancy_namespace=""
auth_token=""
compartment_id=""
to_add_tokens=("mcd_token") #array
to_add_compartments=("MCD") #array
to_add_policies=("mcd_policy") #array

function main() {

echo $to_add_policie_statements
  if [ -e "$HOME/.oci/out" ]
  then
    $(rm -rf $HOME/.oci/out)
  fi

  if [ -e "$HOME/oci_info" ]
  then
    $(rm -rf $HOME/oci_info)
  fi 
    
  if [ -e "$HOME/auth_token" ]
  then
    $(rm -rf $HOME/auth_token)
  fi

    $(mkdir $HOME/.oci/out)
    $(touch $HOME/.oci/out/std.out)
    $(touch $HOME/oci_info)
    $(touch $HOME/auth_token)
    $(touch $HOME/.oci/out/compartment_id)
  
  tenancy_namespace=$(oci os ns get | jq '.data' | sed 's/"//g')
  echo "tenancy_namespace:" $tenancy_namespace >> $HOME/oci_info
  echo "user_ocid:" $user_ocid >> $HOME/.oci/oci_info
  echo "tenancy_ocid:" $tenancy_ocid >> $HOME/oci_info
  echo "docker_registry: icn.ocir.io" >> $HOME/oci_info
  echo "docker_userid: ${tenancy_namespace}/${userid}" >> $HOME/oci_info

  #oci os ns get | jq '.data' | sed 's/"//g' >> $HOME/.oci/out/jobs.out

  # create auth_token
  create_auth_tokens

  # create compartments
  create_compartments

  # create policies
  create_policies
}


function create_auth_tokens() {
  #for row in $(oci iam auth-token list --user-id $user_ocid | jq -c '.data[] | .id , .description'); do
  for row in $(oci iam auth-token list --user-id $user_ocid | jq -c '{"id": .data[].id, "description": .data[].description}'); do
    token_id=$(printf '%s' "$row" | jq -r '.id')
    description=$(printf '%s' "$row" | jq -r '.description')

    if [[ " ${to_add_tokens[@]} " =~ " ${description} " ]]; then
       oci iam auth-token delete --user-id $user_ocid --auth-token-id $token_id --force
       echo "token "{$token_id}" is deleted" >> $HOME/.oci/out/std.out

       auth_token=$(oci iam auth-token create --user-id $user_ocid --description $description | jq '.data.token' | sed 's/"//g')
       echo "auth_token:" $auth_token >> $HOME/oci_info
       echo $auth_token >> $HOME/auth_token
       echo "${auth_token} is sucessfully created." >> $HOME/.oci/out/std.out
    fi
 done
}

function create_compartments() {

  # create compartments
  for compartment in ${to_add_compartments[@]}; do
    compartment_id=$(oci iam compartment list --all --query "data [?\"name\" == '${compartment}'].{\"id\":\"id\"}" | jq '.[].id' | sed 's/"//g')

    if [[ "${compartment_id}" == "" ]]; then
      compartment_id=$(oci iam compartment create -c $tenancy_ocid --description $compartment --name $compartment | jq '.data.id' | sed 's/"//g')
    fi

    echo "compartment_ocid[${compartment}]:" $compartment_id >> $HOME/oci_info
    echo "${compartment} is sucessfully created." >> $HOME/.oci/out/std.out
    echo "[${userid}] ${compartment_id}" >> $HOME/.oci/out/compartment_id
  done
}

function create_policies() {

  # create policies
  for policy in ${to_add_policies[@]}; do
    policy_id=$(oci iam policy list -c ${tenancy_ocid} --all --query "data [?\"name\" == '${policy}'].{\"id\":\"id\"}"  | jq '.[].id' | sed 's/"//g')
  
  if [[ "${policy_id}" == "" ]]; then
    policy_id=$(oci iam policy create -c ${tenancy_ocid} --description ${policy} --name ${policy} --statements '["Allow service OKE to manage all-resources in tenancy", "Allow service FaaS to manage all-resources in tenancy"]' | jq '.data.id' | sed 's/"//g') 
  fi

  echo "[${policy_id}] '${policy}' is sucessfully created." >> $HOME/.oci/out/std.out
  done
}

main

