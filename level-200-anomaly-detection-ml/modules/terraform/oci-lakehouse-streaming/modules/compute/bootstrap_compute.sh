#!bin/bash

# Provision VM.StandardE4.Flex instance with image: Oracle-Linux-8.7-2023.05.24-0, make sure has instance principal access with policies:

# Policies:
# Allow any-user to manage functions-family in compartment id <app compartment id> where all {request.principal.type='instance', request.principal.compartment.id='<compute compartment id>'}
# Allow any-user to manage repos in compartment id <app compartment id> where all {request.principal.type='instance', request.principal.compartment.id='<compute compartment id>'}

echo "LOG: use 'cat /var/log/cloud-init-output.log | grep ^LOG' to track progress."
echo "LOG: use 'cat /var/log/cloud-init-output.log' to track progress closely."
echo "LOG: use 'for i in {1..100}; do cat /var/log/cloud-init-output.log | grep ^LOG; echo \"## $(date)\"; sleep 10; done' to track progress every 10 seconds."
echo "LOG: whoami: $(whoami)"
echo "LOG: sleep to allow for internet access..."
sleep 30
echo "LOG: install fnproject"
curl -LSs https://raw.githubusercontent.com/fnproject/cli/master/install | sh
cp /usr/local/bin/fn /usr/bin/fn
echo "LOG: install repositories required for docker"
dnf install -y dnf-utils zip unzip
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
echo "LOG: install docker"
dnf remove -y runc
dnf install -y docker-ce --nobest
echo "LOG: enable and start the docker service"
systemctl enable docker.service
systemctl start docker.service
echo "LOG: install oci-cli"
dnf -y install oraclelinux-developer-release-el8
dnf install -y python36-oci-cli

echo "LOG: fn commands"
fn create context ${STREAMING_region_id} --provider oracle-ip
fn use context ${STREAMING_region_id}
# fn list context
fn update context api-url https://functions.${STREAMING_region_id}.oci.oraclecloud.com
fn update context oracle.compartment-id ${STREAMING_app_compartment_id}
fn update context oracle.image-compartment-id ${STREAMING_app_compartment_id}
fn update context registry ${STREAMING_region_key}.ocir.io/${STREAMING_ocir_namespace}/${STREAMING_function_name}
echo "LOG: login to docker"
echo "${STREAMING_ocir_user_password}" | docker login -u "${STREAMING_ocir_namespace}/${STREAMING_ocir_user_name}" ${STREAMING_region_key}.ocir.io --password-stdin
echo "LOG: get OCI_Streaming_Pipeline"
wget -P /home/opc https://github.com/paulchyz/OCI_Streaming_Pipeline/archive/refs/heads/${STREAMING_BRANCHNAME}.zip
cd /home/opc
chown opc:opc ${STREAMING_BRANCHNAME}.zip
unzip ${STREAMING_BRANCHNAME}.zip
chown -R opc:opc OCI_Streaming_Pipeline-${STREAMING_BRANCHNAME}
cd /home/opc/OCI_Streaming_Pipeline-${STREAMING_BRANCHNAME}/level-200-anomaly-detection-ml/modules/functions
sed -i "s/name: streaming_fnc/name: ${STREAMING_function_name}/g" func.yaml
echo "LOG: deploy function to app"
fn -v deploy --app streaming_app
echo "LOG: set environment variables for stream.py"
echo "export STREAMING_MESSAGES_ENDPOINT=${STREAMING_MESSAGES_ENDPOINT}" >> /home/opc/.bashrc
echo "export STREAMING_STREAM_OCID=${STREAMING_STREAM_OCID}" >> /home/opc/.bashrc
echo "LOG: Done"