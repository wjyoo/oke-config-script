# Scripting files to make ./kube/config for Oracle Container Engine for Kubernetes
## 
### This script files requires oci script files and already included in this scripts.

# Directory
kube : scripts for making kubernetes config file and other stuff.
oci : scripts for making oci environment files.

# kube script
1. create_kube_cfg.sh
3. kube_setup.sh	
4. prepareapp.sh (complementary)
5. getalltoken.sh (complementary)

# create_kube_cfg.sh
This script reads tsv file and copy kube_setup.sh file to each users home directory and then excute kube_setup.sh.
> Usage : create_kube_cfg.sh [tsv file]
```
tsv file : csv format file including user information file.
<tsv file format : seperated with tab>
no os_account tenent_name user_id user_ocid tenent_ocid
ex) 1      user201 mcd101  twkim9978@gmail.com     ocid1.user.oc1..aaaaaaaamhzom25nd45krt6v2ouqxcglykylnuawoxdxsel3trjy4m6kgw2q    ocid1.tenancy.oc1..aaaaaaaa77jrcspi4lo2ruqdsjyp3nsimvbgi237geemqkfpr72fqdvl7pea
```

# kube_setup.sh
> This script requires oci script invoking in advance. Before executing this script, you should execute oci script.

This script creates ./kube/config file invoking oci script(oci ce cluster create-kubeconfig).
This script doesn't include making kubernetes cluster, so you have to prepare kubernetes cluster by hand in advance for now.
This script include below.
1. Writing to config file of kubernetes cluster information
2. Creating kubernetes secret for OCIR
3. git config setup : This is used for ci/cd lab
4. make kubeproxy alias : This is for kubernetes dashboard per user

# prepareapp.sh
This script is for copying files below to each users.
```
cloud-native-oke.tar
mysql-deployment.yaml
```

# getalltokens.sh
This file is for gathering of all users's auth_token file.
auth_token files are generated by oci script.
