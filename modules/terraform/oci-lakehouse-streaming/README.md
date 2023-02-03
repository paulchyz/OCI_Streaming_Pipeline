# oci-lakehouse-streaming
Deploy your Lakehouse pipeline for streaming!

## Table of Contents

- [Deployment via Resource Manager](#deployment-via-resource-manager)
- [Deployment via CLI Terraform](#deployment-via-cli-terraform)

### Deployment via Resource Manager
#### Prerequisites
- Fully-privileged access to an OCI Tenancy (account).
- Sufficient availability of resources in your OCI Tenancy. You can check resource availability [here](https://cloud.oracle.com/limits?region=home).
#### Note
For general Resource Manager deployment steps, you can refer to [this documentation](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/deploybutton.htm#ariaid-title4). For steps that are specific to this stack, proceed to Step 1.
#### Steps
1. Click the `Deploy to Oracle Cloud` button below, opening the link into a new browser tab.
\
\
In Chrome, Firefox and Safari, you can do this with `CTRL`+`Click` > Select `Open Link in New Tab`.
\
\
[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/scacela/oci-digital-twin-pipeline/archive/refs/tags/v1.0.0.zip)
2. Log into your Oracle Cloud Infrastructure (OCI) tenancy with your user credentials. You will then be redirected to the `Stack Information` section of Resource Manager.
3. In the `Stack Information` section, select the checkbox to confirm that you accept the [Oracle Terms of Use](https://cloudmarketplace.oracle.com/marketplace/content?contentId=50511634&render=inline).
4. In the `Create in compartment` field, select a compartment from the dropdown menu where you wish to deploy the resource that represents the stack as a unit.
5. Click `Next` to proceed to the `Configure Variables` section.
6. For each resource that you wish to deploy, verify that the corresponding checkbox is selected in the `Select Resources` tile. Optionally, you can customize the attributes of each selected resource once an additional tile that presents configuration options for its respective resource appears below.
7. When you are finished editing your variables in the `Configure Variables` section, click `Next` to proceed to the `Review` section.
8. Select the checkbox for `Run Apply`, and click `Create`.
9. You can monitor the deployment by monitoring the `Logs` window. Once the resources in the stack have been provisioned, you can access your resources by following this sub-steps series:
\
\
	<b>Access Your Resources:</b>
	1. Click `Job Resources` to open a page that shows details about the resources that were provisioned.
	2. For each resource that you wish to access, find the name of the resource under the `Name` column. If the name of the resource is hyperlinked, open the link into a new browser tab. If the name of the resource is not hyperlinked, do the following instead:
		1. Copy to your clipboard its identifier, which is listed as the value to the `id` key, which can be found under the `Attributes` column once you click `Show`.
		2. Duplicate your browser tab, and switch to that tab.
		3. Paste the identifier from your clipboard into the search field at the top of the OCI UI, and press `Enter` on your keyboard.
		4. Click the listing that corresponds to your resource once it appears in the search results.

### Deployment via CLI Terraform
#### Prerequisites
- Fully-privileged access to an OCI Tenancy (account).
- Sufficient availability of resources in your OCI Tenancy. You can check resource availability [here](https://cloud.oracle.com/limits?region=home).
- Terraform set up on your local machine. You can access the steps [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm).
#### Steps
1. [Download this project](https://github.com/scacela/oci-digital-twin-pipeline/archive/refs/tags/v1.0.0.zip) to your local machine.
2. [Set up CLI Terraform on your local machine.](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm) 
3. Navigate to project folder on your local machine via CLI.
<pre>
cd &ltYOUR_PATH_TO_THIS_PROJECT&gt
</pre>
4. Open your local copy of [vars.tf](./vars.tf) and edit the values that are assigned to the objects of type variable, which will influence the stack topology according to your preferences.
5. Initialize your Terraform project, downloading necessary packages for the deployment.
<pre>
terraform init
</pre>
6. View the plan of the Terraform deployment, and confirm that the changes described in the plan reflect the changes you wish to make in your OCI environment.
<pre>
terraform plan
</pre>
7. Apply the changes described in the plan, and answer `yes` when prompted for confirmation.
<pre>
terraform apply
</pre>
8. You can track the logs associated with the job by monitoring the output on the CLI. After the deployment has finished, review the output information at the bottom of the logs for instructions on how to access the nodes in the topology.