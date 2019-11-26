#!/bin/bash 

ocicli_setup_file=${1}
#ocicli_setup_file=ocid_cfg_test.tsv
region=ap-seoul-1
fingerprint=48:1a:98:8c:cd:f6:63:4b:fb:4d:8d:26:44:aa:37:f6

[ $# -eq 0 ] && { 
  echo "Usage: $0 ocicli-setup-file [tsv file] "; exit 1; 
}

function main() {
  # clear up error log file
  $(cat /dev/null > logs/error.log)
  $(cat /dev/null > out/jobs.out)
  $(cat /dev/null > out/compartment_ids)
  
  if [ "test" == "${ocicli_setup_file}" ]
  then
    ocicli_setup_file="ocid_cfg_ociuser_test.tsv"
  fi

  # read file for ocicli setup
  if [ -f $ocicli_setup_file ]; then

    # ${A}: osuser, ${B}: tenancy_name, ${C}: oci_user, ${D}: user_ocid, ${E}: tenancy_ocid
    while read A B C D E F
    do
      # create .oci folder
      if [ -e "/home/${B}/.oci" ]
      then
        $(rm -rf /home/${B}/.oci)
        #echo "/home/${B}/.oci folder already exists!!" | tee -a log/error.log # print screen and write log
      fi

      $(mkdir /home/${B}/.oci)     

      # copy keys
      $(cp -u config oci_api_key* oci_setup.sh /home/${B}/.oci)

      # reassign owner user and group
      $(chown -R ${B}:omcd2019 /home/${B}/.oci)
 
      # grant permission
      $(chmod 755 /home/${B}/.oci)
      $(chmod 600 /home/${B}/.oci/*)
      $(chmod +x /home/${B}/.oci/*.sh)

      make_oci_config "${B}" "${E}" "${F}"
      echo "[${B}] oci config file is successfully created!"
      
      oci_setup "${B}" "${D}" "${E}" "${F}"
      echo "[${B}] oci-cli connection is successfully connected!"

    done < $ocicli_setup_file

  else
    echo "Usage: create_ocicli_cfg.sh $0 ocicli-setup-file [tsv file]"
    echo "Please check the usage and required files"
    exit 1; 
  fi   
}

function make_oci_config() {
  echo "user=${2}" >> /home/${1}/.oci/config
  echo "fingerprint=${fingerprint}" >> /home/${1}/.oci/config
  echo "key_file=/home/${B}/.oci/oci_api_key.pem" >> /home/${1}/.oci/config
  echo "tenancy=${3}" >> /home/${1}/.oci/config
  echo "region=${region}" >> /home/${1}/.oci/config
}

function oci_setup() {
  su - ${1} /home/${1}/.oci/oci_setup.sh ${1} ${2} ${3} ${4}

  echo "##${1}##" >> ./out/std.out
  cat /home/${1}/.oci/out/std.out >> ./out/std.out
  cat /home/${1}/.oci/out/compartment_id >> ./out/compartment_ids

  echo " " >> ./out/std.out
}


main


