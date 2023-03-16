# OCI Streaming Pipeline
This document provides instructions for deployment and configuration of a cloud-native streaming and anaylsis pipeline using Oracle Cloud Infrastructure.

## Table of Contents

- [Introduction](#introduction)
- [Objective](#objective)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Which OCI resources will you provision?](#which-oci-resources-will-you-provision)
- [Lab Steps](#lab-steps)
	- [Deploy Infrastructure using Resource Manager](#deploy-infrastructure-using-resource-manager)
	- [Configure Function](#configure-function)
	- [Deploy Service Connector](#deploy-service-connector)
	- [Configure ADW for Stream Processing](#configure-adw-for-stream-processing)
	- [Configure Function Parameters](#configure-function-parameters)
	- [Configure Data Stream](#configure-data-stream)
	- [Run The Stream Pipeline](#run-the-stream-pipeline)
	- [Configure Oracle Analytics Cloud](#configure-oracle-analytics-cloud)
	- [Stop the Data Stream](#stop-the-data-stream)
- [Additional Steps](#additional-steps)
	- [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline)
	- [Troubleshooting Resource Manager Cleanup](#troubleshooting-resource-manager-cleanup)
	- [Data Cleanup](#data-cleanup)
	- [Resource Cleanup](#resource-cleanup)

### Introduction
Data streaming is a powerful tool capable of accelerating business processes and facilitating real-time decision-making across a wide variety of industries and use cases. There are many ways to implement streaming technology, and each solution offers different benefits and drawbacks. The approach documented below is a cloud-native, low-code approach to streaming, covering the complete data lifecycle from ingestion to analysis. This will enable organizations to implement a complete streaming pipeline quickly, without the need to spend valuable time and effort procuring, configuring and managing IT infrastructure.

### Objective
This repository leverages Oracle Cloud's array of infrastructure services to deploy a low-code, end-to-end streaming pipeline. The included Terraform Stack handles resource deployment, and additional configuration steps are documented below. The resulting architecture is a cloud-native streaming pipeline, capable of data ingestion, processing, storage, and analysis.

### System Architecture

![System Architecture](/images/system_architecture.png)

### Prerequisites
To follow this lab, you must have administrative access to all resources within an Oracle Cloud Infrastructure (OCI) tenancy or trial tenancy environment, or to all resources within a compartment in your environment.

### Which OCI resources will you provision?
<details>
<summary>Identity and Access Management (IAM) resources</summary>
<p></p>
<pre>
<b>Compartment</b>: Logical container for resources, which can be accessed only by entities that have been given permission by an administrator in your organization.
<b>Policy</b>: A collection of Policy Statements used to manage access to resources in your OCI environment.
</pre>
</details>
<details>
<summary>Autonomous Data Warehouse (ADW)</summary>
<p></p>
<pre>
Managed data warehouse service that automates provisioning, configuring, securing, tuning, scaling, and backing up of the data warehouse. It includes tools for self-service data loading, data transformations, business models, automatic insights, and built-in converged database capabilities that enable simpler queries across multiple data types and machine learning analysis.
</pre>
</details>
<details>
<summary>Functions</summary>
<p></p>
<pre>
Serverless, event-driven service that lets developers build, run, and scale applications without provisioning or managing any infrastructure. You only pay for the resources used when the function is running. Functions integrate with other OCI services and Oracle SaaS applications.
</pre>
</details>
<details>
<summary>Object Storage Bucket</summary>
<p></p>
<pre>
Securely store any type of data in its native format, with built-in redundancy.
</pre>
</details>
<details>
<summary>Service Connector</summary>
<p></p>
<pre>
</pre>
</details>
<details>
<summary>Streaming</summary>
<p></p>
<pre>
Real-time, serverless, Apache Kafka-compatible event streaming platform for developers and data scientists.
</pre>
</details>
<details>
<summary>Virtual Cloud Network (VCN)</summary>
<p></p>
<pre>
Customizable and private cloud network.
</pre>
</details>

## Lab Steps
### Deploy Infrastructure using Resource Manager
In this section, you will deploy a customized arrangement of Oracle Cloud Infrastructure (OCI) resources, on top of which you will convert your data stream to data that is accessible as structured data from within Autonomous Data Warehouse (ADW).

The infrastructure resources that comprise this customized arrangement are prescribed as Terraform code, which is an approach to <i>infrastructure as code</i> (IaC). OCI supports team-oriented, UI-enabled infrastructure deployment and management using Terraform logic, through a service called Resource Manager. You will create a Resource Manager Stack object, which will act as the platform from which you can deploy and manage the infrastructure resources that underpin the data streaming and conversion process.

1. Click the `Deploy to Oracle Cloud` button below, opening the link into a new browser tab.
	\
	\
	In Chrome, Firefox and Safari, you can do this with `CTRL`+`Click` > Select `Open Link in New Tab`.
	\
	\
	[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/paulchyz/OCI_Streaming_Pipeline/raw/master/modules/terraform/oci-lakehouse-streaming.zip)

2. Log into your Oracle Cloud Infrastructure (OCI) tenancy with your user credentials. You will then be redirected to the `Stack information` section of Resource Manager.
3. In the `Stack information` section, select the checkbox to confirm that you accept the [Oracle Terms of Use](https://cloudmarketplace.oracle.com/marketplace/content?contentId=50511634&render=inline). Leave the `Working Directory` and `Custom Providers` options unchanged. You can update the `Name` and `Description` according to your preference.
4. In the `Create in compartment` field, select a compartment from the dropdown menu where you wish to create the Resource Manager Stack object. If your tenancy environment is new, this compartment will be your root-level compartment. Leave the `Terraform Version` set to the default value, and add `Tags` if desired.

	<i>About Compartments: In OCI, the compartment serves as a logical container of resources. Resources are scoped to a compartment from an Identity and Access Management (IAM) perspective, and are said to be "contained within" a compartment. A selection of users or resources within Oracle may be granted access to specified resources within a compartment using IAM Policy Statements, which can be written by a tenancy administrator.</i>

5. Click `Next` to proceed to the `Configure Variables` section.
6. In the `Name Your Resources` field, enter a string that will be included within the names of the resources deployed by the Stack.
7. In the `Parent Compartment` field, select the compartment where you wish for the OCI resources to be deployed from the Resource Manager Stack object. For this lab, one of the deployed resources will be a new compartment, which will contain the other resources. For users with a new tenancy, this will be the root compartment.
8. In the `Region` field, select the region where you wish to deploy your resources. For this lab, this will be the value that corresponds to your home region. This should be shown in the upper right-hand side of the page, and appear in a format similar to `US East (Ashburn)`. Make a note of the string you select for this value, called the `region identifier`, which we will refer to later in this lab.
9. Update the `Name of New Compartment (Prefix)`, `Description for New Compartment`, `IAM Policy Name (Prefix)`, and `IAM Policy Description` if desired, and keep `Enable Delete for Compartment` and `Deploy IAM Policy` selected.
10. For this lab, we will deploy a subset of resources that can deployed using the Terraform code. In the `Select Resources` tile, ensure that only the checkboxes that correspond to the below indicated services are selected to deploy the corresponding services:

	- `Deploy Autonomous Data Warehouse (ADW)`
	- `Deploy Object Storage`
	- `Deploy Streaming`
	- `Deploy Virtual Cloud Network (VCN)`
11. <i>Optional</i>: In the `ADW Admin Password` field, change the password to one you would like to use to access Autonomous Data Warehouse. Remember this password for use later on.
12. The remaining details on the `Configure Variables` page can be left as their default values or updated to fit your needs.
13. When you are finished editing your variables in the `Configure Variables` section, click `Next` to proceed to the `Review` section.
14. Select the checkbox for `Run Apply`, and click `Create`. You can monitor the deployment by monitoring the `Logs` window.
15. Once the selected resources have been provisioned, click `Job resources` to open a page that shows details about the resources that were provisioned.
16. Copy the name of the deployed compartment to your clipboard for later use. You can find the name of the compartment under the `Name` column, where the value under `Type` appears as `oci_identity_compartment`.
17. Keep this browser tab open, as we will refer to this page later in this lab. Duplicate the current browser tab, and proceed using the new browser tab.
	\
	\
	<b>Congratulations! You've successfully deployed a custom stack of OCI resources using Resource Manager!</b>

### Configure Function
In this section, you will configure an instance of the serverless OCI Functions service, called a Function. The Function will act as a prescription for custom logic to be installed and executed on a machine that gets dynamically provisioned when the designated Function endpoint is invoked. This dynamic allocation of infrastructure is what makes the OCI Functions service a serverless platform. The custom logic is sourced from a container image repository located within the Oracle Cloud Infrastructure Registry (OCIR).  
	\
In this pipeline, the Function invocation will carry out the necessary transformations to the data present in the data stream, so that the data is accessible in Object Storage and the Autonomous Data Warehouse (ADW) instance.

1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Click on the dropdown under `Compartment` on the left-hand side of the page. Paste the value from your clipboard, which is the name of the compartment that was deployed from the Resource Manager stack, and then select the same compartment name that appears on the dropdown menu.
3. A Function is logically "contained within" an Application, so you will create an Application object. Click `Create application`, and enter values for the corresponding parameters:

	- `Name` : `streaming_app`
	- `VCN` : <i>Ensure that the compartment is set to the deployed compartment. Then, select the deployed VCN, which is named `ST_vcn` unless customized.</i>
	- `subnets` : <i>Ensure that the compartment is set to the deployed compartment. Then, select the deployed subnet, which is named `Subnet1` unless customized.</i>
	\
	\
	Then, click `Create`.
4. Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`. This will open a command-line interface (CLI) environment from which we will programmatically configure and deploy a serverless instance of OCI Functions, called a Function. The subsequent steps will walk you through how to configure and deploy your Function using the Cloud Shell CLI.
5. Select the `context` object, which is named according to the region in which you are operating. Use the `region identifier` value you selected when configuring your Terraform stack.
	\
	\
	Note that in the example provided below, `us-ashburn-1` is the value provided as the `region identifier` used to represent the `US East (Ashburn)` region. Replace this with the correct value based on your selection when you deployed the Stack.

	```
	fn use context us-ashburn-1
	```
	Note that you can list the values for `region identifier` available to your Cloud Shell environment using the following command:

	```
	fn list context
	```
6. Update the `context` with the <i>O</i>racle <i>C</i>loud <i>Id</i>entifier (OCID) of the compartment where we deployed our stack. You can find the compartment OCID on the browser tab from your Resource Manager deployment, where stack information is available. Navigate to this browser tab, and click `Outputs` on the left-hand side of the page. Copy the string under the `Value` column that corresponds to `iam_compartment_id` under the `Key` column. Use this value to replace `YOUR_COMPARTMENT_OCID` in the command indicated below.
	```
	fn update context oracle.compartment-id YOUR_COMPARTMENT_OCID
	```
7. Over the next few steps, you will generate the values you will use to generate an Oracle Coud Infrastructure Registry (OCIR) container image repository. This repository is where your Function code will be hosted, available to serverless Function machines as they are dynamically allocated. Although programmatic methods of obtaining the values are offered for rapid setup, front-end methods are offered as alternatives for some of the values.
	\
	\
	First, prepare a name to use for your Function. Use `streaming_fnc` as a prefix specific to this lab, and as a suffix, add the unique string associated with your deployment in order to provide uniqueness to the name of the Function instance within your OCI user account.
	\
	\
	You can find the unique string from your Terraform deployment on the browser tab from your Resource Manager deployment, where stack information is available. Navigate to this browser tab, and click `Outputs` on the left-hand side of the page. Copy the string under the `Value` column that corresponds to `random_string` under the Key column.
	\
	\
	Copy and paste, but do not yet execute, the following command into Cloud Shell. Replace `UNIQUESTRING` with the string unique to your deployment, then run the command.

	```
	export STREAMING_FUNCTION_NAME=streaming_fnc_UNIQUESTRING
	```
8. These commands will generate the value for the `region key` that corresponds to the `region identifier`, and the region in which you are configuring your Function.

	```
	export STREAMING_CONTEXT_REGION_IDENTIFIER=$(fn inspect context | grep api-url | grep -Po '(?<=functions.).*(?=.oci)')
	export STREAMING_CONTEXT_REGION_KEY=$(oci iam region list | jq -r ".data[] | select(.name == \"$STREAMING_CONTEXT_REGION_IDENTIFIER\").key" | tr '[:upper:]' '[:lower:]')
	```
	Alternatively, the `region key` can be obtained by finding the `region key` that corresponds to the `region identifier` you used when selecting your `context` object from the table shown in [this documentation](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#ariaid-title2). Use a lower-case representation of the `region key` when replacing the placeholder value (`your_region_key`) in the command indicated below, and then run the command.

	```
	export STREAMING_CONTEXT_REGION_KEY=your_region_key
	```
9. Programatically generate the tenancy name.

	```
	export STREAMING_TENANCY_NAME=$(oci iam tenancy get --tenancy-id $OCI_TENANCY | jq -r .data.name)
	```
	Alternatively, the tenancy name can be obtained by navigating to the user icon on the upper right-hand side of the page, hovering over the dropdown menu, and reading the name next to `Tenancy:`. The value can also be obtained by clicking on this option, and locating the `Name` field on the tenancy page. Replace the placeholder value (`your_tenancy_name`) in the command indicated below, and then run the command.

	```
	export STREAMING_TENANCY_NAME=your_tenancy_name
	```
10. Generate the OCIR container image repository for your Function.

	```
	fn update context registry ${STREAMING_CONTEXT_REGION_KEY}.ocir.io/${STREAMING_TENANCY_NAME}/${STREAMING_FUNCTION_NAME}
	```
11. You will construct a command to sign into OCIR. On your browser tab with Cloud Shell, minimize Cloud Shell using the `_` icon, and navigate to the user icon on the upper right-hand side of the page, hovering over the dropdown menu, click `User settings`. Copy the name of your user in large text at the top of the page, including the `oracleidentitycloudservice/` prefix if present. Restore Cloud Shell, replace the placeholder value (`your_user_extended_name`) in the command indicated below, and then run the command.

	```
	export STREAMING_USER_EXTENDED_NAME=your_user_extended_name
	```
12. When the following command is run, you will be prompted for a password, which will be the result of an Auth Token that you will generate. Run the command, and do not supply a value until later instructions.

	```
	docker login -u "${STREAMING_TENANCY_NAME}/${STREAMING_USER_EXTENDED_NAME}" ${STREAMING_CONTEXT_REGION_KEY}.ocir.io
	```
13. Minimize Cloud Shell, and click `Auth Tokens` on the left-hand side of the page. Click `Generate Token`, and supply the `Description` field with a friendly description, such as `ocir login for streaming app`. Click `Generate Token`. Copy the generated token, click `Close`, restore Cloud Shell, supply the token as your password, and press `Enter`.
	\
	\
	Note that if you lose the generated token, you may repeat this step to generate a new one.
14. Verify your setup by listing Application objects in the compartment.

	```
	fn list apps
	```
15. Copy and paste, but do not yet execute, the following command into Cloud Shell. Replace `UNIQUESTRING` with the string unique to your deployment, then run the command. This will generate boilerplate code for your Function. You will customize this code with logic provided later in this lab.

	```
	fn init --runtime python streaming_fnc_UNIQUESTRING
	```
16. Switch into the generated directory, replacing `UNIQUESTRING` with the string unique to your deployment in the command below.

	```
	cd streaming_fnc_UNIQUESTRING
	```
17. Copy the contents of [func.py](./modules/functions/func.py) from this repository to your clipboard. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	\
	On Cloud Shell, open the copy of `func.py` that you generated using the `fn init` command:

	```
	vi func.py
	```
	Replace boilerplate logic with custom logic:

	1. Navigate to the top of the file by typing `gg`.
	2. Remove all of the contents in the file by typing `dG`.
	3. Activate `insert` mode by typing `i`.
	4. Paste the contents that you copied from your clipboard.
	5. Press `ESC` to escape `insert` mode.
	6. Save your edits and exit the `vi` editor by typing `:wq`, then pressing `Enter`.

18. Copy the contents of [func.yaml](./modules/functions/func.yaml) from this repository to your clipboard. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	\
	On Cloud Shell, open the copy of `func.yaml` that you generated using the `fn init` command:

	```
	vi func.yaml
	```
	Replace boilerplate logic with custom logic:

	1. Navigate to the top of the file by typing `gg`.
	2. Remove all of the contents in the file by typing `dG`.
	3. Activate `insert` mode by typing `i`.
	4. Paste the contents that you copied from your clipboard.
	5. Press `ESC` to escape `insert` mode.
	6. Save your edits and exit the `vi` editor by typing `:wq`, then pressing `Enter`.

19. Copy the contents of [requirements.txt](./modules/functions/requirements.txt) from this repository to your clipboard. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	\
	On Cloud Shell, open the copy of `requirements.txt` that you generated using the `fn init` command:

	```
	vi requirements.txt
	```
	Replace boilerplate logic with custom logic:

	1. Navigate to the top of the file by typing `gg`.
	2. Remove all of the contents of the file by typing `dG`.
	3. Activate `insert` mode by typing `i`.
	4. Paste the contents that you copied from your clipboard.
	5. Press `ESC` to escape `insert` mode.
	6. Save your edits and exit the `vi` editor by typing `:wq`, then pressing `Enter`.

20. Now that you have finished making the necessary edits to your Function logic, deploy your Function to OCIR, and associate it with the Application object you created.

	```
	fn -v deploy --app streaming_app
	```
	<b>Congratulations! You've successfully deployed your Function!</b>

### Deploy Service Connector
In this section, you will deploy a Service Connector instance, using the <i>O</i>racle <i>C</i>loud <i>Id</i>entifier (OCID) of your Function and the same Resource Manager Stack you created [earlier in this lab](#deploy-infrastructure-using-resource-manager).

1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. The new compartment will end with the four-character alphanumeric string unique to your deployment.
3. Click on the hyperlinked Application object you created, called `streaming_app`.
4. Click on the hyperlinked Function object you created, called `streaming_fnc_UNIQUESTRING`, where `UNIQUESTRING` appears as the string unique to your deployment.
5. Copy the Function OCID, which can be found next to `OCID:`. You will supply this value in a later step when you edit your Resource Manager Stack.
6. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `stacks` into the search field. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
7. Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.
8. Click on the hyperlinked Resource Manager Stack object you created for this lab.
9. Click `Edit` > Click `Edit stack` > Click `Next`.
10. In the `Region` field, select the same region where you deployed your resources previously.
11. In the `Select Resources` tile, allow the checkboxes that are already checked to remain selected, and also select the checkbox next to `Deploy Service Connector Hub (SCH)`.
12. In the `Service Connector Hub (SCH)` tile, paste the Function OCID into the `Function OCID` field.
13. Click `Next` to proceed to the `Review` section.
	\
	Note that with this selection of resources, the only change that will be made to the existing deployment will be an additional Service Connector instance. The remainder of the deployment will remain unchanged.
14. Select the checkbox for `Run apply`, and click `Save changes`. You can monitor the deployment by monitoring the `Logs` window.
15. Once the selected resources have been provisioned, click `Job resources` to open a page that shows details about the resources that were provisioned.
16. Keep this browser tab open, as we will refer to this page later in this lab. Duplicate the current browser tab, and proceed using the new browser tab.
	\
	\
	<b>Congratulations! You've successfully added Service Connector to your existing deployment using Resource Manager!</b>

### Configure ADW for Stream Processing
In this section, you will set up the following items in your Autonomous Data Warehouse (ADW) instance:
- <b>JSON Collection</b>: This object will store data points from a data stream in JSON format.
- <b>Database View</b>: This object will contain a virtual table that enables querying of the JSON data as if it were a relational table.

1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `adw` into the search field. Click the listing that appears on the page that contains the words `Autonomous Data Warehouse`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Database object you created.
4. Click `Database actions`. Note that you may need to allow pop-ups in your browser if launching the new page fails.
5. Enter your username and password for your ADW instance. For this lab, the default values are as indicated below. If you specified a custom password for your ADW instance, replace the default value with the custom value.
	\
	`Username`: `ADMIN`\
	`Password`: `Streaming!2345`
6. You have reached the `Database Actions` interface for your ADW instance. Click on the tile labeled `JSON`. Feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
7. Click `Create Collection`.
8. Enter `STREAMDATA` into the `Collection Name` field. Use upper-case letters for this name, because the endpoint address for the JSON Collection will incorporate this provided name, and it is case-sensitive.
9. Click `Create`.
10. Click on the hamburger menu in the upper left-hand side of the page, and click `SQL` under `Development`. Feel free to close the pop-up that warns that you are logged in as `ADMIN` user by clicking `X`. Also, feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
11. Copy and paste the following PL/SQL code snippet into the editor. Once this code snippet has been executed, you will have created a database view, which uses a stored query to create a virtual table that can be queried to return the JSON collection data in a relational format.

	```
	-- Create database view to return relational data from JSON collection
	CREATE OR REPLACE VIEW STREAMDATA_VIEW AS 
	SELECT stream, TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF') key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA,
		JSON_TABLE(STREAMDATA.JSON_DOCUMENT, '$'
			COLUMNS (
				STREAM VARCHAR2(40) PATH '$.stream',
				KEY VARCHAR2(100) PATH '$.key',
				PARTITION NUMBER PATH '$.partition',
				OFFSET NUMBER PATH '$.offset',
				TIMESTAMP NUMBER PATH '$.timestamp',
				EQUIPMENT_ID NUMBER PATH '$.equipment_id',
				VIBRATION_AMPLITUDE NUMBER PATH '$.vibration_amplitude',
				VIBRATION_FREQUENCY NUMBER PATH '$.vibration_frequency',
				TEMPERATURE NUMBER PATH '$.temperature',
				HUMIDITY NUMBER PATH '$.humidity'
			)
		) ORDER BY KEY DESC;
	```
	\
	Click on the `Run Script` icon at the top of the editor to execute this code snippet as a script.
	\
	\
	<b>Congratulations! You've successfully configured your ADW for stream processing!</b>

### Configure Function Parameters
In this section, you will supply environment variables to be made available to your Function machines while they execute their associated logic. These environment variables will supply the necessary values for your streaming pipeline to integrate with some of the resources in our deployment, work end-to-end. These environment variables must be set using `Key`:`Value` pairs, where each pair represents the name of an environment variable, and its associated value, respectively.

1. Navigate to the Database Actions interface for your Autonomous Data Warehouse (ADW) instance as [previously done](#configure-adw-for-stream-processing).
2. Click on the hamburger menu in the upper left-hand side of the page, and click `RESTful Services ad SODA` under `Related Services`.
3. Click `Copy` to copy the base URL of the Oracle REST Data Services (ORDS) HTTPS interface to your clipboard.
4. In another browser tab with your main OCI Console open, navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
5. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
6. Click on the hyperlinked Application object you created, called `streaming_app`.
7. Click on the hyperlinked Function object you created, called `streaming_fnc_UNIQUESTRING`.
8. Click `Configuration` on the left-hand side of the page, and add the `Key`:`Value` pair indicated below into their respective text fields:
	\
	\
	`ords-base-url` : <i>Paste the base URL for the ORDS HTTPS interface</i>\
	\
	Click `+` to add the pair to the Function configuration.
9. Next, you will retrieve the name of your Object Storage Bucket that will store processed data. Duplicate your current browser tab. Navigate to the hamburger menu at the top-left of the webpage, and type `buckets` into the search field. Click the listing that appears on the page that contains the word `Buckets`.
10. Your viewing scope should already be set according to the compartment that was deployed from the Resource Manager Stack. If this is not the case, select that compartment from the dropdown under `Compartment`.
11. Identify the listed Bucket object whose name does <b>NOT</b> include the string `raw`, and copy the name of this listing to your clipboard.
12. Return to the browser tab showing the Function page, and add the `Key`:`Value` pair indicated below into their respective text fields:
	\
	\
	`streaming-bucket-processed` : <i>Paste the name of the Object Storage Bucket for processed data</i>\
	\
	Click `+` to add the pair to the Function configuration.
13. Add the `Key`:`Value` pairs indicated below. The `Value` values are to be set as defaults used for this lab. If you specified a custom password for your ADW instance, replace the default value with the custom value.
	
	<b>Important: `json-collection-name` is case-sensitive. `db-schema` and `db-user` must be lowercase.</b>
	\
	\
	`json-collection-name` : `STREAMDATA`\
	`db-schema` : `admin`\
	`db-user` : `admin`\
	`dbpwd-cipher` : `Streaming!2345`
	\
	\
	<b>Congratulations! You've successfully configured your Function with the environment variables needed to run the data stream!</b>

### Configure Data Stream
In this section, you will configure the data stream from Cloud Shell to simulate the transmission of manufacturing data to your Streaming instance's Messages Endpoint in OCI.

1. Navigate to the hamburger menu at the top-left of the webpage, and type `streaming` into the search field. Click the listing that appears on the page that contains the words `Streaming` and `Messaging`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked name under `Name` column, which corresponds to the Stream resource that you created from your Resource Manager deployment.
4. Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`.
5. Copy the contents of [stream.py](./modules/compute/stream.py) from this repository to your clipboard. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	On Cloud Shell, navigate to the home directory, and then open a new file named `stream.py`.

	```
	cd;vi stream.py
	```

	Populate the file with the desired logic:

	1. Activate `insert` mode by typing `i`.
	2. Paste the contents that you copied from your clipboard.
	3. Press `ESC` to escape `insert` mode.
	4. Save your edits and exit the `vi` editor by typing `:wq`, then pressing `Enter`.
6. Copy and paste, but do not yet execute, the following command into Cloud Shell. On the page showing details about your Streaming instance. Copy the Streaming OCID by clicking `Copy` next to `OCID:` to your clipboard. Replace the placeholder value (`YOUR_STREAM_OCID`) by pasting the contents of your clipboard into its place, then execute the command.

	```
	echo "export STREAMING_STREAM_OCID=YOUR_STREAM_OCID" >> ~/.bashrc; source ~/.bashrc
	```
	This environment variable will be used by the script that will trigger the data stream to identify your Streaming instance.
	\
	\
	By appending the `export` command to your `~/.bashrc` file, this variable will be automatically assigned for each Cloud Shell session.
7. Copy and paste, but do not yet execute, the following command into Cloud Shell. On the page showing details about your Streaming instance. Copy the string that corresponds to `Messages Endpoint` to your clipboard. Replace the placeholder value (`YOUR_MESSAGES_ENDPOINT`) by pasting the contents of your clipboard into its place, then execute the command.

	```
	echo "export STREAMING_MESSAGES_ENDPOINT=YOUR_MESSAGES_ENDPOINT" >> ~/.bashrc; source ~/.bashrc
	```
	This environment variable will be used by the script that will trigger the data stream to identify the Messages Endpoint your Streaming instance.
	\
	\
	By appending the `export` command to your `~/.bashrc` file, this variable will be automatically assigned for each Cloud Shell session.
8. Execute the following command into Cloud Shell.

	```
	echo "export STREAMING_OCI_CONFIG_FILE_LOCATION=/etc/oci/config" >> ~/.bashrc; source ~/.bashrc
	```
	This environment variable will be used by the script that will trigger the data stream to identify the location of your OCI API credentials in your Cloud Shell environment.
	\
	\
	By appending the `export` command to your `~/.bashrc` file, this variable will be automatically assigned for each Cloud Shell session.\
	\
	Note that if you wish to review the values set for environment variables in this lab, you can execute the following command in Cloud Shell.

	```
	env | grep ^STREAMING_
	```
	<b>Congratulations! You've successfully configured your Cloud Shell and are ready to run the data stream!</b>

### Run The Stream Pipeline
In this section, you will run the data stream from Cloud Shell to simulate streaming manufacturing data, then you will view the output from each step of the pipeline.

1. If you do not have a Cloud Shell session prepared from [the previous section](#configure-data-stream), open the Cloud Shell and follow steps 6-8 to configure the necessary environment variables.
2. Navigate to your home directory and initiate the data stream.

	```
	cd;python stream.py
	```
3. You should see output in the Cloud Shell displaying data points that are being sent into the stream. For example:

	```
	SENT: [{"equipment_id": 1234, "vibration_amplitude": 275.0, "vibration_frequency": 1066.0, "temperature": 54.9, "humidity": 30.27}]
	SENT: [{"equipment_id": 1234, "vibration_amplitude": 270.75, "vibration_frequency": 963.0, "temperature": 59.28, "humidity": 30.09}]
	SENT: [{"equipment_id": 1234, "vibration_amplitude": 246.75, "vibration_frequency": 919.0, "temperature": 61.32, "humidity": 29.4}]
	```
4. Navigate to your Stream on the `Streaming` page on OCI: 
	Click on the hamburger menu at the top-left of the webpage, and type `streaming` into the search field. Click the listing that appears on the page that contains the words `Streaming` and `Messaging`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked Streaming object you created from your Resource Manager deployment.
5. Click `Load Messages`.  This will show the data points that have been ingested by the Streaming service.
6. Navigate to your Service Connector instance:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `service connector` into the search field. Click the listing that appears on the page that contains the words `Service Connector Hub` and `Messaging`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked Service Connector object you created from your Resource Manager deployment.
7. Click `Metrics` from the Resources list on the left-hand side of the Service Connector page. This page provides detailed metrics about the Service Connector's data ingestion, Function task, and Object Storage target. About 1 minute after starting the data stream, you should see data populating under categories like `Bytes read from source`, `Bytes written to task`, and `Bytes written to target`. The source is the Streaming service, the task is the Function, and the target is Object Storage.
8. Navigate to your Object Storage Buckets:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `buckets` into the search field. Click the listing that appears on the page that contains the words `Buckets`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked Bucket object that <b>does not</b> contain the word `raw`.
9. If you do not see data in this Bucket, it can take a minute or two to populate. There is a refresh button under the `More Actions` menu in the middle of the page.  Periodically refresh the Bucket until you see populated data. This data is processed into CSV format and has been inserted into this Bucket by the Function triggered from the Service Connector.
\
\
If data has not populated within this Bucket after a minute or two, please review the [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline) section.
10. In the navigation ribbon on the top of the page, click `Object Storage` to return to the list of Buckets. Then click on the hyperlinked Bucket object that <b>does</b> contain the word `raw`.
11. If you do not see data in this Bucket, it can take a minute or two to populate. There is a refresh button under the `More Actions` menu in the middle of the page.  Periodically refresh the Bucket until you see populated data. This data is the unprocessed data that was transmitted to the Streaming service and has been inserted into this Bucket by the Service Connector.
\
\
If data has not populated within this Bucket after a minute or two, please review the [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline) section.
12. Navigate to your Autonomous Data Warehouse (ADW) instance:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `adw` into the search field. Click the listing that appears on the page that contains the words `Autonomous Data Warehouse`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked Database object you created from your Resource Manager deployment.
13. Click `Database actions`. Note that you may need to allow pop-ups in your browser if launching the new page fails.
14. Enter your username and password for your ADW instance. For this lab, the default values are as indicated below. If you specified a custom password for your ADW instance, replace the default value with the custom value.
	\
	`Username`: `ADMIN`\
	`Password`: `Streaming!2345`
15. Click on the tile labeled `JSON`. In the query editor, leave the query as `{}` and click the green `Run Query` button to run the query. This will return all JSON elements in the JSON database. There is one JSON element for each data point that was tramsitted into the stream.
16. Click on the hamburger menu in the upper left-hand side of the page, and click `SQL` under `Development`.
17. Copy and paste the following PL/SQL query into the editor. This query returns the JSON data from STREAMDATA. The data points are contained within the `BLOB` element in each row.

	```
	-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
	SELECT * FROM STREAMDATA;
	```
	\
	Highlight the PL/SQL statement, then click on the round green `Run Statement` icon at the top of the editor to execute this statement.
18. Copy and paste the following PL/SQL query into the editor. This query returns the data in STREAMDATA_VIEW. This data has been converted to table format by the Stored Procedure we configured earlier in this lab. Converting to table format allows the data to be easily queried for things like data visualization.

	```
	-- Select all data in STREAMDATA_VIEW
	SELECT * FROM STREAMDATA_VIEW ORDER BY KEY DESC;
	```
	\
	Highlight the PL/SQL statement, then click on the round green `Run Statement` icon at the top of the editor to execute this statement.
	\
	\
	<b>Congratulations! You've successfully run and viewed the output of the data stream!</b>

### Configure Oracle Analytics Cloud
In this section, you will deploy and configure Oracle Analytics Cloud (OAC) to visualize the data stream.

1. Return to a browser tab where you can access the main OCI Console. Click on the hamburger menu at the top-left of the webpage, and type `analytics` into the search field. Click the listing that appears on the page that contains the words `Analytics Cloud` and `Analytics`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click `Create Instance`.
4. Note that the Oracle Analytic Cloud (OAC) instance requires a name, and that all other values can be left as default for this lab. Use `streaming_oac` as a prefix specific to this lab, and as a suffix, add the unique string associated with your deployment in order to provide the required uniqueness to the name of the OAC instance within the tenancy.
	\
	\
	You can find the unique string from your Terraform deployment on the browser tab from your Resource Manager deployment, where stack information is available. Navigate to this browser tab, and click `Outputs` on the left-hand side of the page. Copy the string under the `Value` column that corresponds to `random_string` under the `Key` column.
5. Click `Create`.
6. While the OAC instance is provisioning, navigate back to the Autonomous Data Warehouse (ADW) page on OCI: 
	Click on the hamburger menu at the top-left of the webpage, and type `adw` into the search field. Click the listing that appears on the page that contains the words `Autonomous Data Warehouse`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked ADW object you created from your Resource Manager deployment.
7. Click `Database connection`, then click `Download wallet`. Enter a password for the wallet. This password may be of your choosing. For simplicity, you may choose `Streaming!2345`, which is the password provided in this lab for the `admin` user in ADW. Then click `Download`. The .zip file that gets downloaded to your local machine is the wallet, and will be required to connect OAC to ADW. Click `Close` on the `Database connection` window.
8. Return to the OAC page:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `analytics` into the search field. Click the listing that appears on the page that contains the words `Analytics Cloud` and `Analytics`. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack. Click on the hyperlinked OAC object you created.
9. If the OAC instance does not have a `State` of `Active`, wait for it to finish provisioning.
10. Once the instance is active, click `Analytics Home Page` to open Oracle Analytics Cloud.
11. Click `Create` in the top-right corner of the OAC home page, then click `Connection`. Select `Oracle Autonomous Data Warehouse`.
12. Enter a name for the connection. For this lab, use `streaming_adw_conn`, as this name is referred to later in this lab. Then, drag and drop the downloaded wallet file into the `Client Credentials` box. The `Description` field is optional. Leave the remaining fields unchanged.
13. The `Username` and `Password` sections are referencing the ADW instance, so enter `admin` for the username, and `Streaming!2345` for the password, or your own custom password if you chose to set a custom password.
14. Click `Save`. The connection will validate, and then save. If the connection fails, double check your username and password for the database. <i>Note: The password to be supplied here is the password for the `admin` user in ADW, which is `Streaming!2345`, or your own custom password if you chose to set a custom password.</i>
15. Click `Create` in the top-right corner of the OAC home page, then click `Dataset`. Select the database connection you just created, named `streaming_adw_conn`.
16. On the left-hand side of the page, expand the `Schemas` dropdown menu by clicking the arrow next to `Schemas`. Then, expand the dropdown menu of the `ADMIN` schema that appears on the `Schemas` dropdown menu. Drag and drop `STREAMDATA_VIEW` into the main canvas area to add it to the dataset. This will load a preview of the data.
17. Convert `PARTITION`, `OFFSET`, `TIMESTAMP`, and `EQUIPMENT_ID` to attributes. To do this, click on the pound sign next to each column's name and select `Attribute`.
18. Click the `Save` icon in the top-right corner of the page, which appears as an image of a hard-drive. Provide a name for the dataset. For this lab, use `streaming_dataset`, as this name is referred to later in this lab. The `Description` field is optional. Click `OK`.
19. Click the `Back` arrow in the top-left corner of the page to return to the OAC home page.
20. Click `Create` in the top-right corner of the OAC home page, then click `Workbook`. In the popup titled `Add Data`, Select the dataset you just created, named `streaming_dataset`, then click `Add to Workbook`. For now, close the `Auto Insights` window on the right-hand side of the page by clicking on the light-bulb icon.
21. Hold `command` if using a Mac or `control` if using a PC, then select `KEY` and `VIBRATION_AMPLITUDE` from the data pane on the left-hand side of the page. Drag and drop these data elements onto the canvas. This will create a line chart.
22. Select `VIBRATION_FREQUENCY`, `TEMPERATURE`, and `HUMIDITY` from the data pane, and drag and drop these data elements in the `Values (Y-Axis)` section of the visualization pane just to the right of the data pane. Be sure not to drop the data elements on top of `VIBRATION_AMPLITUDE`, as that will add the new elements in place of the existing data, rather than in addition to the existing data.
23. Right click on the Canvas tab on the bottom of the page labeled `Canvas 1` and select `Canvas Properties`.
24. Click on `Disabled` next to `Auto Refresh Data` to switch it to `Enabled`. Click `Sec` to switch to `Min`, and change the value from `30` to `1`. Click `OK`. This will refresh the canvas every minute.
25. Click the `Refresh Data` button in the top-right toolbar. It looks like a white play button with an arrow circling around it. This will start the auto refresh process.
26. Click the `Save` icon in the top-right corner of the page. Provide a name for the workbook and click `Save`.
27. Click the `Preview` button in the top-right toolbar to view the dashboard as an end user. It looks like an outline of a play button. Click the `Refresh Data` button in the toolbar to start the auto refresh process in this view.
\
\
<b>Congratulations! You are now visualizing the output of your completed streaming pipeline!</b>

![OAC Workbook](/images/oac_workbook.png)

### Stop the Data Stream

To stop the data stream, navigate to the page with the Cloud Shell running `stream.py`, click within the Cloud Shell window, and press `ctrl` + `c` to stop the script. 
\
\
<b>Thank you, and congratulations on completing this workshop!</b>

## Additional Steps
### Troubleshooting and Logging when Running the Streaming Pipeline

If the stream pipeline is not functioning as expected, the first thing to check is the function configuration page to ensure that all the configuration keys and values are correct. Review the steps in [Configure Function Parameters](#configure-function-parameters), and pay special attention to case sensitivity and eliminating leading/trailing spaces. Any innaccuracy in these parameters will cause the pipeline to fail. 
\
\
If the function configuration is correct and the pipeline is still not running properly, the following steps will walk through how to enable logging for the function. These logs can provide additional information about certain points of failure.

1. Navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Application object you created, called `streaming_app`.
4. Click `Logs` in the `Resources` menu on the left side of the Application page.
5. Locate the `Function Invocation Logs` row in the `Logs` window in the middle of the page, and click on the switch icon in the `Enable Log` column.
6. Ensure that the correct compartment is selected, and leave the other options as default. This will auto-create the default Log Group and provide a standard name and retention policy. Click `Enable Log`.
7. Click the hyperlined log name from the `Log Name` column to view the Log.
8. Run the stream, and refresh this Log page to view the output of the function. Basic error messages have been included in the function code to help identify where the function is failing.

### Troubleshooting Resource Manager Cleanup
If an error is encountered and the Destroy job reaches the `Failed` state as a result, identify which scenario listed below best describes the error encountered, and follow the steps associated with that scenario.

- [Compartment being reported as in the `ACTIVE` state](#compartment-being-reported-as-in-the-active-state)
- [Some other resource is indicated in the error message](#some-other-resource-is-indicated-in-the-error-message)

#### Compartment being reported as in the `ACTIVE` state
This may be due to the presence of resources that have been provisioned within the compartment that are not associated with the Resource Manager Stack. The compartment will remain in the `ACTIVE` state so long as there are any resources within it, as a measure to protect resources from being unintentionally deleted. The steps to ensure that there are no resources in the compartment are indicated below.

1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `compartments` into the search field. Click the listing that appears on the page that contains the word `Compartments` and `Identity`.
2. Click on the hyperlinked name of the deployed compartment if it is listed on the page, or of any parent compartment until your reach the deployed compartment, and then click on the hyperlinked name of the deployed compartment. Note that if there are many compartments in your tenancy, using the page navigation at the bottom right-hand side of the page may be necessary.
3. Click `Work Requests` under `Resources` on the left-hand side of the page.
4. Hover over the `i` icon next to the text `Failed` in the `Status` column under `Work Requests`. The message that appears should indicate the resources that are dependent on the compartment, and are preventing the compartment from being deprovisioned.
5. Identify any resource that is dependent upon the resource indicated in the error message.
6. For each such resource:
	1. Navigate to the corresponding resource page.
	2. Delete the resource from that page.
7. Repeat the steps indicated in the [Deprovision Infrastructure Deployed via Resource Manager Stack](#deprovision-infrastructure-deployed-via-resource-manager-stack) section to resume the deprovisioning process from the Resource Manager Stack. If unsuccessful, repeat this section until all resources that depend on the compartment have been deprovisioned.

#### Some other resource is indicated in the error message
The steps indicated below walk through a workaround for deprovisioning any resources associated with the error.

1. Identify any resource that is dependent upon the resource indicated in the error message.
2. For each such resource:
	1. Navigate to the corresponding resource page.
	2. Delete the resource from that page.
3. Repeat the previous step, for the resource indicated in the error message.
4. Repeat the steps indicated in the [Deprovision Infrastructure Deployed via Resource Manager Stack](#deprovision-infrastructure-deployed-via-resource-manager-stack) section to resume the deprovisioning process from the Resource Manager Stack. If unsuccessful, repeat this section until all resources indicated in any error messages have been deprovisioned.

### Data Cleanup
The following steps describe the process of clearing the data out of the pipeline. This can be useful when you want to start a fresh stream of data without any residual data from previous pipeline usage. This process involves clearing the JSON collection and clearing both Object Storage Buckets.
- [Clearing the JSON Collection](#clearing-the-json-collection)
- [Clearing the Object Storage Buckets](#clearing-the-object-storage-buckets)

#### Clearing the JSON Collection

1. Navigate to Autonomous Data Warehouse (ADW) Database Actions:
	1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `adw` into the search field. Click the listing that appears on the page that contains the words `Autonomous Data Warehouse`.
	2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
	3. Click on the hyperlinked Database object you created.
	4. Click `Database actions`, and enter your username and password for your ADW instance if prompted.
2. Click on the tile labeled `JSON`.
3. Click the trash can icon in the toolbar above the JSON query editor. This button is labeled `Delete All Documents in the list` when hovering over it.
4. Click `OK` to confirm.

#### Clearing the Object Storage Buckets

1. Navigate to Object Storage:
	1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `buckets` into the search field. Click the listing that appears on the page that contains the word `Buckets`.
	2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
2. For each Bucket:
	1. Click on the hyperlinked Bucket name
	2. Locate the row in the `Objects` window for the highest level folder in the Bucket, and click on the three vertically-oriented dots on the far right-hand side of the row.
	3. Click `Delete Folder`.
	4. Enter the folder name into the confirmation window as prompted, and click `Delete`.

After these steps, the JSON collection and Object Storage Bucktes are empty and ready to recieve new stream data.

### Resource Cleanup
The following steps walk through the process of deprovisioning the resources that were deployed in this lab. This will terminate billing for infrastructure resources, and re-allocate capacity for other projects.

- [Deprovision Oracle Analytics Cloud (OAC) instance](#deprovision-oracle-analytics-cloud-oac-instance)
- [Deprovision Application](#deprovision-application)
- [Remove Cloud Shell artifacts](#remove-cloud-shell-artifacts)
- [Deprovision Infrastructure Deployed via Resource Manager Stack](#deprovision-infrastructure-deployed-via-resource-manager-stack)
- [Deprovision Resource Manager Stack instance](#deprovision-resource-manager-stack-instance)

#### Deprovision Oracle Analytics Cloud (OAC) instance

1. Navigate to OAC: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `analytics` into the search field. Click the listing that appears on the page that contains the word `Analytics Cloud` and `Analytics`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked OAC instance name.
4. Click on the `More actions` button, and click `Delete` from the dropdown menu that appears. Then, click `Delete`.

#### Deprovision Application
Deprovisioning the Application will deprovision the associated Function as well.

1. Navigate to Application: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the word `Applications` and `Functions`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Application instance name.
4. Click on the `Delete` button. Then, click `Delete` on the pop-up window that appears to confirm.

#### Remove Cloud Shell artifacts
These steps will walk through the process of removing the folders, files, and persisting environment variables set up on Cloud Shell for this project.

1. Navigate to Cloud Shell: Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`.
2. Remove `stream.py` and your `streaming_fnc_UNIQUESTRING` folder, replacing `UNIQUESTRING` when running the following command in Cloud Shell.

	```
	rm -rf stream.py streaming_fnc_UNIQUESTRING
	```
3. Open the copy of `~/.bashrc`, and remove any export commands that have been appended to the file in this lab using the `vi` text editor and associated `vi`-related commands.

	```
	vi ~/.bashrc
	```
	1. Navigate to the bottom of the file by typing `G`.
	2. For each line that starts with `export STREAMING_`, remove the line by typing `dd`.
	3. Save your edits and exit the `vi` editor by typing `:wq`, then pressing `Enter`.
4. Exit out of Cloud Shell using the `X` icon.

#### Deprovision Infrastructure Deployed via Resource Manager Stack
These steps will walk through the process of performing the `Destroy` operation in the Resource Manager Stack instance to deprovision the resources that were deployed from running the `Apply` action from the same Resource Manager Stack instance.

1. Navigate to Resource Manager: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `stacks` into the search field. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
2. Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.
3. Click on the hyperlinked Resource Manager Stack object you created for this lab.
4. Click on the red `Destroy` button at the top of the page.
5. Notice the caution message shown on the pane that appears. Then, click `Destroy`. You can monitor the deprovisioning process by monitoring the `Logs` window.
\
\
If an error is encountered and the Destroy job reaches the `Failed` state as a result, please review the [Troubleshooting Resource Manager Cleanup](#troubleshooting-resource-manager-cleanup) section.

#### Deprovision Resource Manager Stack instance
These steps will walk through the process of deprovisioning the Resource Manager Stack instance itself. As a best practice, ensure that the resources that were deployed using the Resource Manager Stack have been deprovisioned using the `Destroy` operation from the Resource Manager Stack page. This will eliminate the need to deprovision each resource individually.

1. Navigate to Resource Manager: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `stacks` into the search field. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
2. Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.
3. Click on the hyperlinked Resource Manager Stack object you created for this lab.
4. Ensure that the resources that were provisioned using the Resource Manager Stack have been deprovisioned using the `Destroy` operation: Locate the `Jobs` section in the middle of the page. Ensure that the `Type` and `State` values of the top-most (i.e. most recent) job read `Destroy` and `Succeeded`, respectively.
5. Click on the `More actions` button, and click `Delete stack` from the dropdown menu that appears. Then, click `Delete`.