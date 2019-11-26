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
      # create .kube folder
      if [ -e "/home/${B}/.kube" ]
      then
        $(rm -rf /home/${B}/.kube)
      fi

      $(mkdir /home/${B}/.kube)     

      # copy setupfile 
      $(cp -u kube_setup.sh /home/${B}/.kube)

      # reassign owner user and group
      $(chown -R ${B}:omcd2019 /home/${B}/.kube)
 
      # grant permission
      $(chmod 755 /home/${B}/.kube)
      $(chmod 600 /home/${B}/.kube/*)
      $(chmod +x /home/${B}/.kube/*.sh)

      #make_kube_config "${B}" "${E}" "${F}"
      echo "[${B}] oci config file is successfully created!"
      
      kube_setup "${B}" "${D}" "${E}" "${F}"
      echo "[${B}] kube-cli connection is successfully connected!"

    done < $ocicli_setup_file

  else
    echo "Usage: create_kubecli_cfg.sh $0 ocicli-setup-file [tsv file]"
    echo "Please check the usage and required files"
    exit 1; 
  fi   
}

#function make_kube_config() {
#}

function kube_setup() {
  su - ${1} /home/${1}/.kube/kube_setup.sh ${1} ${2} ${3} ${4}

  echo "##${1}##" >> ./out/jobs.out
  cat /home/${1}/.kube/out/jobs.out >> ./kube/jobs.out
  echo " " >> ./out/jobs.out
}


main


