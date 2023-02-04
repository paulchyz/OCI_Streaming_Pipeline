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
	- [Initiate Data Stream](#initiate-data-stream)

### Introduction
Data streaming is a powerful tool capable of accelerating business processes and facilitating real-time decision-making across a wide variety of industries and use cases. There are many ways to implement streaming technology, and each solution offers different benefits and drawbacks. The approach documented below is a cloud-native, low-code approach to streaming, covering the complete data lifecycle from ingestion to analysis. This will enable organizations to implement a complete streaming pipeline quickly without the need to spend valuable time and energy procuring, configuring and managing IT infrastructure.

### Objective
This repository leverages Oracle Cloud's array of infrastructure services to deploy a low-code, end-to-end streaming pipeline. The included Terraform Stack handles resource deployment, and additional configuration steps are documented below. The resulting architecture is a cloud-native streaming pipeline, capable of data ingestion, processing, strorage, and analysis.

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
Manage and move data between OCI services, and trigger Functions for lightweight, serverless data processing. Also supports management and movement of data between OCI services and third-party services.
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

2. Log into your Oracle Cloud Infrastructure (OCI) tenancy with your user credentials. You will then be redirected to the `Stack Information` section of Resource Manager.
3. In the `Stack Information` section, select the checkbox to confirm that you accept the [Oracle Terms of Use](https://cloudmarketplace.oracle.com/marketplace/content?contentId=50511634&render=inline).
4. In the `Create in compartment` field, select a compartment from the dropdown menu where you wish to create the Resource Manager Stack object. If your tenancy environment is new, this compartment will be your root-level compartment. In OCI, the compartment serves as a logical container of resources. Resources are scoped to a compartment from an Identity and Access Management (IAM) perspective, and are said to be "contained within" a compartment. A selection of users or resources within Oracle may be granted access to specified resources within a compartment using IAM Policy Statements, which can be written by a tenancy administrator.
5. Click `Next` to proceed to the `Configure Variables` section.
6. In the `Parent Compartment` field, select the compartment where you wish for the OCI resources to be deployed from the Resource Manager Stack object. For this lab, one of the deployed resources will be a new compartment, which will contain the other resources. For users with a new tenancy, this will be the root compartment.
7. In the `Region` field, select the region where you wish to deploy your resources. For users with a new tenancy, this will be the value that corresponds to your home region. This should be shown in the upper right-hand side of the page, and appear in a format similar to `US East (Ashburn)`. Make a note of the string you select for this value, called the `region identifier`, which we will refer to later in this lab.
6. For this lab, we will deploy a subset of resources that can deployed using the Terraform code. In the `Select Resources` tile, ensure that only the checkboxes that correspond to the below indicated services are selected to deploy the corresponding services:

	- `Deploy Autonomous Data Warehouse (ADW)`
	- `Deploy Object Storage`
	- `Deploy Streaming`
	- `Deploy Virtual Cloud Network (VCN)`
7. When you are finished editing your variables in the `Configure Variables` section, click `Next` to proceed to the `Review` section.
8. Select the checkbox for `Run Apply`, and click `Create`. You can monitor the deployment by monitoring the `Logs` window.
9. Once the selected resources have been provisioned, click `Stack Resources` to open a page that shows details about the resources that were provisioned.
10. Make a note of the name of the compartment you deployed. You can find the name of the compartment under the `Name` column, where the value under `Type` appears as `oci_identity_compartment`.
11. Keep this browser tab open, as we will refer to this page later in this lab. Duplicate the current browser tab, and proceed using the new browser tab.
	\
	\
	<b>Congratulations! You've successfully deployed a custom stack of OCI resources using Resource Manager!</b>

### Configure Function
In this section, you will configure an instance of the serverless OCI Functions service, called a Function. The Function will act as a prescription for custom logic to be installed and executed on a machine that gets dynamically provisioned when the designated Function endpoint is invoked. This dynamic allocation of infrastructure is what makes the OCI Functions service a serverless platform. The custom logic is sourced from a container image repository located within the Oracle Cloud Infrastructure Registry (OCIR).
\
In this pipeline, the Function invocation will carry out the necessary transformations to the data structures present in the datastream, so that the data is made accessible as structured data from within your Autonomous Data Warehouse (ADW) instance.
1. In your main OCI Console, navigate to the hamburger menu at the top left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. A Function is logically "contained within" an Application, so you will create an Application object. Click `Create application`, and enter values for the corresponding parameters:

	- `Name` : `streaming_app`
	- `VCN` : <i>Ensure that the compartment is set to the deployed compartment. Then, select the deployed VCN.</i>
	- `subnets` : <i>Ensure that the compartment is set to the deployed compartment. Then, select the deployed subnet.</i>
	\
	\
	Then, click `Create`.
4. Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`. This will open a command-line interface (CLI) environment from which we will programatically configure and deploy a serverless instance of OCI Functions, called a Function. The subsequent steps will walk you through how to configure and deploy your Function using the Cloud Shell CLI.
5. Select the `context` object, which is named according to the region in which you are operating. Use the `region identifier` value you selected when configuring your Terraform stack.
	\
	\
	Note that in the example provided below, `us-ashburn-1` is the value provided as the `region identifier` used to represent the `US East (Ashburn)` region.
	```
	fn use context us-ashburn-1
	```
	Note that you can list the values for `region identifier` available to your Cloud Shell environment using the following command:
	```
	fn list context
	```
6. Update the `context` with the <i>O</i>racle <i>C</i>loud <i>id</i>entifier (OCID) of the compartment where we deployed our stack. You can find the compartment OCID on the browser tab from your Resource Manager deployment, where stack information is available. Navigate to this browser tab, and click `Show` next to the listing of type `oci_identity_compartment`. Copy the string that corresponds to `id` (not `compartment_id`), <b>not</b> including the quotation marks. Use this value to replace `YOUR_COMPARTMENT_OCID` in the command indicated below.
	```
	fn update context oracle.compartment-id YOUR_COMPARTMENT_OCID
	```
7. Over the next few steps, you will generate the values you will use to generate an Oracle Coud Infrastructure Registry (OCIR) container image repository. This repository is where your Function code will be hosted, available to serverless Function machines as they are dynamically allocated.
	\
	\
	Although programatic methods of obtaining these values are offered for rapid setup, front-end methods are offered as alternatives for some of these values.
	\
	\
	First, prepare a name to use for your Function.
	```
	export STREAMING_FUNCTION_NAME=streaming_fnc
	```
8. These commands will generate the value for the `region key` that corresponds to the `region identifier`, and the region in which you are configuring your Function.
	```
	export STREAMING_CONTEXT_REGION_IDENTIFIER=$(fn inspect context | grep api-url | grep -Po '(?<=functions.).*(?=.oci)')
	export STREAMING_CONTEXT_REGION_KEY=$(oci iam region list | jq -r ".data[] | select(.name == \"$STREAMING_CONTEXT_REGION_IDENTIFIER\").key" | tr '[:upper:]' '[:lower:]')
	```
	Alternatively, the `region key` can be obtained by finding the `region key` that corresponds to the `region identifier` you used when selecting your `context` object from the table shown in this [documentation](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#ariaid-title2). Use a lower-case representation of the `region key` when replacing the placeholder value (`your_region_key`) in the command indicated below, and then run the command.
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
	fn update context registry ${STREAMING_CONTEXT_REGION_KEY}.ocir.io/${STREAMING_OS_NS}/${STREAMING_FUNCTION_NAME}
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
15. Generate boilerplate code for your Function. You will customize this code with logic provided later in this lab.
	```
	fn init --runtime python streaming_fnc_logic
	```
16. Switch into the generated directory
	```
	cd streaming_fnc_logic
	```
17. Copy the contents of [func.py](./modules/functions/service_connector_stream_processing/func.py) using the `Copy raw contents` button, which appears as two overlapping squares. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	\
	On Cloud Shell, open the copy of `func.py` that you generated using the `fn init` command:
	```
	vi func.py
	```
	Replace boilerplate logic with custom logic:

	- Navigate to the top of the file by typing `gg`.
	- Remove all of the contents in the file by typing `dG`.
	- Activate `insert` mode by typing `i`.
	- Paste the contents that you copied from your clipboard.
	- Press `ESC` to escape `insert` mode.
	- Save your edits and exit the `vi` editor by typing `:wq`.

18. Copy the contents of [requirements.txt](./modules/functions/service_connector_stream_processing/requirements.txt) using the `Copy raw contents` button, which appears as two overlapping squares. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	\
	On Cloud Shell, open the copy of `requirements.txt` that you generated using the `fn init` command:
	```
	vi requirements.txt
	```
	Replace boilerplate logic with custom logic:

	- Navigate to the top of the file by typing `gg`.
	- Remove all of the contents of the file by typing `dG`.
	- Activate `insert` mode by typing `i`.
	- Paste the contents that you copied from your clipboard.
	- Press `ESC` to escape `insert` mode.
	- Save your edits and exit the `vi` editor by typing `:wq`.

19. Now that you have finished making the necessary edits to your Function logic, deploy your Function to OCIR, and associate it with the Application object you created.
	```
	fn -v deploy --app streaming_app
	```
	<b>Congratulations! You've successfully deployed your Function!</b>

### Deploy Service Connector
In this section, you will deploy a Service Connector instance, using the <i>O</i>racle <i>C</i>loud <i>id</i>entifier (OCID) of your Function and the same Resource Manager Stack you created [earlier in this lab](#deploy-infrastructure-using-resource-manager).

1. In your main OCI Console, navigate to the hamburger menu at the top left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Application object you created, called `streaming_app`.
4. Click on the hyperlinked Function object you created, called `streaming_fnc`.
5. Copy the Function OCID, which can be found next to `OCID:`. You will supply this value in a later step when you edit your Resource Manager Stack.
6. In your main OCI Console, navigate to the hamburger menu at the top left of the webpage, and type `stacks` into the search field. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
7. Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.
8. Click on the hyperlinked Resource Manager Stack object you created for this lab.
9. Click `Edit` > Click `Edit Stack` > Click `Next`.
10. In the `Region` field, select the same region where you deployed your resources previously.
11. In the `Select Resources` tile, allow the checkboxes that are already checked to remain selected, and also select the checkbox next to `Deploy Service Connector Hub (SCH)`.
12. In the `Service Connector Hub (SCH)` tile, paste the Function OCID into the `Function OCID` field.
13. Click `Next` to proceed to the `Review` section.
	\
	Note that with this selection of resources, the only change that will be made to the existing deployment will be an additional Service Connector instance. The remainder of the deployment will remain unchanged.
14. Select the checkbox for `Run Apply`, and click `Create`. You can monitor the deployment by monitoring the `Logs` window.
15. Once the selected resources have been provisioned, click `Stack Resources` to open a page that shows details about the resources that were provisioned.
16. Keep this browser tab open, as we will refer to this page later in this lab. Duplicate the current browser tab, and proceed using the new browser tab.
	\
	\
	<b>Congratulations! You've successfully added Service Connector to your existing deployment using Resource Manager!</b>

### Configure ADW for Stream Processing
In this section, you will set up the following items in your Autonomous Data Warehouse (ADW) instance:
- <b>JSON Collection</b>: This object will store data points from a data stream in JSON format.
- <b>Table</b>: This object will represent the JSON keys of the data points in the data stream as fields (column headers), and their respective values as records (row entries).
- <b>Stored Procedure</b>: This object will contain the logic used to insert the new entries of stream data sourced from the JSON Collection.
- <b>Scheduler</b>: This object will execute the Stored Procedure on a minutely basis.

1. In your main OCI Console, navigate to the hamburger menu at the top left of the webpage, and type `adw` into the search field. Click the listing that appears on the page that contains the words `Autonomous Data Warehouse`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Application object you created.
4. Click `Database actions`. Note that you may need to allow pop-ups in your browser if launching the new page fails.
5. Enter your username and password for your ADW instance. For this lab, the default values are as follows:
	\
	`Username`: `ADMIN`\
	`Password`: `Streaming!2345`
6. You have reached the `Database Actions` interface for your ADW instance. Click on the tile labeled `JSON`. Feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
7. Click `Create Collection`.
8. Enter `streamdata` into the `Collection Name` field. Use lower-case letters for this name, because the endpoint address for the JSON Collection will incorporate this provided name, and letter case will be a distinguishing property of the endpoint address.
9. Click `Create`.
10. Click on the hamburger menu in the upper left-hand side of the page, and click `SQL` under `Development`.
11. Click on the tile labeled `SQL`. Feel free to close the pop-up that warns that you are logged in as `ADMIN` user by clicking `X`. Also, feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
12. Copy and paste the following PL/SQL code snippet into the editor. Once this code snippet has been executed, you will have created a table with the columns that you will later populate with stream data.
	```
	-- Create STREAMDATA_TABLE
	create table STREAMDATA_TABLE
	(
	    STREAM VARCHAR2(40),
	    KEY TIMESTAMP,
	    PARTITION NUMBER,
	    OFFSET NUMBER,
	    TIMESTAMP NUMBER,
	    EQUIPMENT_ID NUMBER,
	    VIBRATION_AMPLITUDE NUMBER,
	    VIBRATION_FREQUENCY NUMBER,
	    TEMPERATURE NUMBER,
	    HUMIDITY NUMBER
	);
	```
	\
	Click on the `Run Script` icon at the top of the editor to execute this code snippet as a script. The `Run Script` icon resembles a sheet of paper behind a green play button.
13. Delete the PL/SQL code from your editor, and replace it with the following code. Once this code snippet has been executed, you will have created a stored procedure, which will be used to insert new entries of stream data from the JSON Collection into the table you previously created.
	```
	-- Stored procedure to insert new JSON data into table
	CREATE PROCEDURE UPDATE_STREAMDATA_TABLE 
	AS 
	BEGIN 
	   INSERT INTO ADMIN.STREAMDATA_TABLE SELECT stream, TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF'), partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity FROM STREAMDATA, JSON_TABLE(JSON_DOCUMENT, '$' COLUMNS(stream, key, partition, offset, timestamp, equipment_id, vibration_amplitude, vibration_frequency, temperature, humidity)) WHERE TO_TIMESTAMP(key, 'YYYY-MM-DD HH24:MI:SS.FF') NOT IN (SELECT KEY FROM ADMIN.STREAMDATA_TABLE);
	END UPDATE_STREAMDATA_TABLE;
	```
	\
	Click on the `Run Script` icon at the top of the editor to execute this code snippet as a script.
14. Delete the PL/SQL code from your editor, and replace it with the following code. Once this code snippet has been executed, you will have created a <i>D</i>ata<i>b</i>ase <i>M</i>anagement <i>S</i>ystem (DBMS) Scheduler, which will trigger the stored procedure you previously created, on a minutely basis.
	```
	-- DBMS scheduled job to execute stored procedure at a regular interval
	BEGIN
	  DBMS_SCHEDULER.CREATE_JOB (
	   job_name           =>  'collection_to_table_job',
	   job_type           =>  'STORED_PROCEDURE',
	   job_action         =>  'ADMIN.UPDATE_STREAMDATA_TABLE',
	   start_date         =>  SYSTIMESTAMP,
	   repeat_interval    =>  'FREQ=MINUTELY; INTERVAL=1',
	   enabled            =>  TRUE);
	END;
	```
15. Delete the PL/SQL code from your editor, and replace it with the following code. Once this code snippet has been executed, you will have enabled your ADW instance to act as a resource principal, so that API calls can be made from the ADW instance to interact with the other resources in your OCI environment, as per your IAM Policy Statement configuration. For this lab, the ADW instance will be accessing your Object Storage Bucket that will store processed data.
	```
	EXEC DBMS_CLOUD_ADMIN.ENABLE_RESOURCE_PRINCIPAL();
	```
	<b>Congratulations! You've successfully configured your ADW for stream processing!</b>

### Configure Function Parameters
In this section, you will supply environment variables to be made available to your Function machines while they execute their associated logic. These environment variables will supply the necessary values for your streaming pipeline to integrate with some of the resources in our deployment, work end-to-end. These environment variables must be set using `Key`:`Value` pairs, where each pair represents the name of an environment variable, and its associated value, respectively.

1. Navigate to the Database Actions interface for your ADW instance as [previously done](#create-json-collection-in-adw).
2. Click on the hamburger menu in the upper left-hand side of the page, and click `RESTful Services ad SODA` under `Related Services`.
3. Click `Copy` to copy the base URL of the Oracle REST Data Services (ORDS) HTTPS interface to your clipboard.
4. In another browser tab with your main OCI Console open, navigate to the hamburger menu at the top left of the webpage, and type `functions` into the search field. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
5. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
6. Click on the hyperlinked Application object you created, called `streaming_app`.
7. Click on the hyperlinked Function object you created, called `streaming_fnc`.
8. Click `Configuration` on the left-hand side of the page, and add the `Key`:`Value` pair indicated below into their respective text fields:
	\
	\
	`ords-base-url` : <i>Paste the base URL for the ORDS HTTPS interface</i>\
	\
	Click `+` to add the pair to the Function configuration.
9. Next, you will retrieve the name of your Object Storage Bucket that will store processed data. Duplicate your current browser tab. Navigate to the hamburger menu at the top left of the webpage, and type `buckets` into the search field. Click the listing that appears on the page that contains the word `Buckets`.
10. Your viewing scope should already be set according to the compartment that was deployed from the Resource Manager Stack. If this is not the case, select that compartment from the dropdown under `Compartment`.
11. Identify the listed Bucket object whose name does not include the string `raw`, and copy the name of this listing to your clipboard.
12. Return to the browser tab showing the Function page, and add the `Key`:`Value` pair indicated below into their respective text fields:
	\
	\
	`streaming-bucket-processed` : <i>Paste the name of the Object Storage Bucket for processed data</i>\
	\
	Click `+` to add the pair to the Function configuration.
13. Add the `Key`:`Value` pairs indicated below. The `Value` values are to be set as defaults used for this lab.
	\
	\
	`json-collection-name` : `STREAMDATA`\
	`db-schema` : `ADMIN`\
	`db-user` : `ADMIN`\
	`dbpwd-cipher` : `Streaming!2345`
	\
	\
	<b>Congratulations! You've successfully configured your Function with the environment variables needed to run the data stream!</b>

### Initiate Data Stream
In this section, you will launch the data stream from Cloud Shell to simulate the transmission of manufacturing data to your Streaming instance's Messages Endpoint in OCI.

1. Navigate to the hamburger menu at the top left of the webpage, and type `streaming` into the search field. Click the listing that appears on the page that contains the words `Streaming` and `Messaging`.
2. Click on the dropdown under `Compartment`, and select the compartment that was deployed from the Resource Manager Stack.
3. Click on the hyperlinked Streaming object you created from your Resource Manager deployment.
4. Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`.
5. Copy the contents of [stream.py](./modules/compute/datastream/stream.py) using the `Copy raw contents` button, which appears as two overlapping squares. You will replace boilerplate code with this custom logic using the `vi` text editor and associated `vi`-related commands.
	\
	On Cloud Shell, open a new file named `stream.py`.
	```
	vi stream.py
	```

	Populate the file with the desired logic:

	- Activate `insert` mode by typing `i`.
	- Paste the contents that you copied from your clipboard.
	- Press `ESC` to escape `insert` mode.
	- Save your edits and exit the `vi` editor by typing `:wq`.
6. Copy and paste, but do not yet execute, the following command into Cloud Shell. On the page showing details about your Streaming instance. Copy the Streaming OCID by pressing Copy next to `OCID:` to your clipboard. Then, replace the placeholder value (`YOUR_STREAM_OCID`) by pasting the contents of your clipboard into its place.
	```
	export STREAMING_STREAM_OCID=YOUR_STREAM_OCID
	```
	This command will be used by the script that will trigger the data stream to identify your Streaming instance.
7. Copy and paste, but do not yet execute, the following command into Cloud Shell. On the page showing details about your Streaming instance. Copy the Messages Endpoint by pressing Copy next to `Messages Endpoint:` to your clipboard. Then, replace the placeholder value (`YOUR_MESSAGES_ENDPOINT`) by pasting the contents of your clipboard into its place.
	```
	export STREAMING_MESSAGES_ENDPOINT=YOUR_MESSAGES_ENDPOINT
	```
	This command will be used by the script that will trigger the data stream to identify the Messages Endpoint your Streaming instance.
8. Execute the following command into Cloud Shell.
	```
	export STREAMING_OCI_CONFIG_FILE_LOCATION=/etc/oci/config
	```
	This command will be used by the script that will trigger the data stream to identify the location of your OCI API credentials in your Cloud Shell environment.\
	\
	Note that if you wish to review the values set for environment variables in this lab, you can execute the following command.
	```
	env | grep ^STREAMING_
	```
9. Initiate the data stream.
	```
	python stream.py
	```