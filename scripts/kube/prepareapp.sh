#!/bin/bash 

ocicli_setup_file=${1}
#ocicli_setup_file=kube_cfg_test.tsv
region=ap-seoul-1
fingerprint=48:1a:98:8c:cd:f6:63:4b:fb:4d:8d:26:44:aa:37:f6

[ $# -eq 0 ] && { 
  echo "Usage: $0 kubecli-setup-file [tsv file] "; exit 1; 
}

function main() {
  # clear up error log file
  $(cat /dev/null > logs/error.log)
  $(cat /dev/null > out/jobs.out)
  
  if [ "test" == "${ocicli_setup_file}" ]
  then
    ocicli_setup_file="kube_cfg_ociuser_test.tsv"
  fi

  # read file for ocicli setup
  if [ -f $ocicli_setup_file ]; then

    # ${A}: osuser, ${B}: tenancy_name, ${C}: oci_user, ${D}: user_ocid, ${E}: tenancy_ocid
    while read A B C D E F
    do

      # copy setupfile 
      $(rm -rf /home/${B}/cloud-native-oke.tar)
      $(rm -rf /home/${B}/cloud-native-oke)
      $(rm -rf /home/${B}/mysql-deployment.yaml)
      $(cp -u cloud-native-oke.tar /home/${B}/)
      $(cp -u mysql-deployment.yaml /home/${B}/)
      tar -xvf /home/${B}/cloud-native-oke.tar -C /home/${B}/
      $(rm -rf /home/${B}/cloud-native-oke.tar)

      # reassign owner user and group
      $(chown -R ${B}:omcd2019 /home/${B}/cloud-native-oke)
      $(chown -R ${B}:omcd2019 /home/${B}/mysql-deployment.yaml)
 
      # grant permission

    done < $ocicli_setup_file

  else
    echo "Please check the usage and required files"
    exit 1; 
  fi   
}

main


