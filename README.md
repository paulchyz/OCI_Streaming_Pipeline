# OCI Streaming Pipeline
This document provides instructions for deployment and configuration of a cloud-native streaming and anaylsis pipeline using Oracle Cloud Infrastructure.

## Table of Contents

1. [Introduction](#introduction)
2. [Objective](#objective)
3. [System Architecture](#system-architecture)
4. [Prerequisites](#prerequisites)
5. [Which OCI resources will you provision?](#which-oci-resources-will-you-provision)
6. [Lab Steps](#lab-steps)
	1. [Deploy Infrastructure using Resource Manager](#deploy-infrastructure-using-resource-manager)
	2. [Configure AJD for Stream Processing](#configure-ajd-for-stream-processing)
	3. [Run The Stream Pipeline](#run-the-stream-pipeline)
	4. [Configure Oracle Analytics Cloud](#configure-oracle-analytics-cloud)
	5. [Stop the Data Stream](#stop-the-data-stream)
7. [Additional Steps](#additional-steps)
	1. [Data Cleanup](#data-cleanup)
	2. [Resource Cleanup](#resource-cleanup)
	3. [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline)
	4. [Troubleshooting Resource Manager Cleanup](#troubleshooting-resource-manager-cleanup)

### Introduction
Data streaming is a powerful tool capable of accelerating business processes and facilitating real-time decision-making across a wide variety of industries and use cases. There are many ways to implement streaming technology, and each solution offers different benefits and drawbacks. The approach documented below is a cloud-native, low-code approach to streaming, covering the complete data lifecycle from ingestion to analysis. This will enable organizations to implement a complete streaming pipeline quickly, without the need to spend valuable time and effort procuring, configuring and managing IT infrastructure.

### Objective
This repository leverages Oracle Cloud's array of infrastructure services to deploy a low-code, end-to-end streaming pipeline. The included Terraform Stack handles resource deployment, and additional configuration steps are documented below. The resulting architecture is a cloud-native streaming pipeline, capable of data ingestion, processing, storage, and analysis.

### System Architecture

![System Architecture](/images/system_architecture.png)
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>

### Prerequisites
To follow this lab, you must have the following in place:
- Administrative access to all resources within an Oracle Cloud Infrastructure (OCI) tenancy or trial tenancy environment, or to all resources within a compartment in your environment
- Sufficient resource availability in your OCI environment within your home region to deploy an enclosing compartment, and in the region preferred for deployment of other resources. You can check resource availability within the region indicated on-screen on the [limits page](https://cloud.oracle.com/limits?region=home).

### Which OCI resources will you provision?
<details>
<summary>Identity and Access Management (IAM) resources</summary>
<p></p>

- <b>Compartment</b>: Logical container for resources, which can be accessed only by entities that have been given permission by an administrator in your organization.

- <b>Policy</b>: A collection of Policy Statements used to manage access to resources in your OCI environment.
</details>
<details>
<summary>Autonomous JSON Database (AJD)</summary>
<p></p>
Oracle Autonomous JSON Database is a cloud document database service that makes it simple to develop JSON-centric applications. It features NoSQL-style document APIs (Oracle SODA and Oracle Database API for MongoDB), serverless scaling, high performance ACID transactions, comprehensive security, and low pay-per-use pricing. Autonomous JSON Database automates provisioning, configuring, tuning, scaling, patching, encrypting, and repairing of databases, eliminating database management and delivering 99.95% availability.
</details>
<details>
<summary>Compute</summary>
<p></p>
Oracle Cloud Infrastructure (OCI) provides fast, flexible, and affordable compute capacity to fit any workload need, from high performance bare metal instances and flexible VMs to lightweight containers and serverless computing.
</details>
<details>
<summary>Functions</summary>
<p></p>
Oracle Cloud Infrastructure (OCI) Functions is a serverless compute service that lets developers create, run, and scale applications without managing any infrastructure. Functions have native integrations with other Oracle Cloud Infrastructure services and SaaS applications. Because Functions is based on the open source Fn Project, developers can create applications that can be easily ported to other cloud and on-premises environments. Code based on Functions typically runs for short durations, stateless and run for a single purpose of logic. Customers pay only for the resources they use.
</details>
<details>
<summary>Object Storage</summary>
<p></p>
Oracle Cloud Infrastructure (OCI) Object Storage enables customers to securely store any type of data in its native format. With built-in redundancy, OCI Object Storage is ideal for building modern applications that require scale and flexibility, as it can be used to consolidate multiple data sources for analytics, backup, or archive purposes.
</details>
<details>
<summary>Oracle Analytics Cloud (OAC)</summary>
<p></p>
The Oracle Analytics platform is a cloud native service that provides the capabilities required to address the entire analytics process including data ingestion and modeling, data preparation and enrichment, and visualization and collaboration, without compromising security and governance. Embedded machine learning and natural language processing technologies help increase productivity and build an analytics-driven culture in organizations. Start on-premises or in the cloud—Oracle Analytics supports a hybrid deployment strategy, providing flexible paths to the cloud.
</details>
<details>
<summary>Service Connector Hub</summary>
<p></p>
Service Connector Hub helps cloud engineers manage and move data between Oracle Cloud Infrastructure (OCI) services and from OCI to third-party services. Unlike competing cloud offerings, Service Connector Hub provides a central place for describing, executing and monitoring data movements between services, such as Logging, Object Storage, Streaming, Logging Analytics, and Monitoring. It can also trigger Functions for lightweight data processing and Notifications to set up alerts.
</details>
<details>
<summary>Streaming</summary>
<p></p>
Oracle Cloud Infrastructure (OCI) Streaming service is a real-time, serverless, Apache Kafka-compatible event streaming platform for developers and data scientists. Streaming is tightly integrated with OCI, Database, GoldenGate, and Integration Cloud. The service also provides out-of-the-box integrations for hundreds of third-party products across categories such as DevOps, databases, big data, and SaaS applications.
</details>
<details>
<summary>Virtual Cloud Network (VCN)</summary>
<p></p>
Oracle Cloud Infrastructure (OCI) Virtual Cloud Networks (VCNs) provide customizable and private cloud networks in Oracle Cloud Infrastructure (OCI). Just like a traditional data center network, the VCN provides customers with complete control over their cloud networking environment. This includes assigning private IP address spaces, creating subnets and route tables, and configuring stateful firewalls.
</details>

<sub>[Back to top](#oci-streaming-pipeline)</sub>

## Lab Steps
### Deploy Infrastructure using Resource Manager
In this section, you will deploy a customized arrangement of Oracle Cloud Infrastructure (OCI) resources, on top of which you will convert your data stream to data that is accessible as structured data from within Autonomous JSON Database (AJD).

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
6. In the `Parent Compartment` field, select the compartment where you wish for the OCI resources to be deployed from the Resource Manager Stack object. For this lab, one of the deployed resources will be a new compartment, which will contain the other resources. For users with a new tenancy, this will be the root compartment.
7. In the `Home Region` field, select the value that corresponds to your home region, as the compartment referenced in your stack configuration is globally-scoped, and must be deployed using the home region. You can identify your home region by checking the upper right-hand side of the page, where it appears in a format similar to `US East (Ashburn)`.
8. In the `Custom Region` field, the region where you wish to deploy the regionally-scoped resources that are referenced in your stack configuration. <b>Make a note of the string you select for this value,</b> called the `region identifier`, which we will refer to later in this lab.
9. Update the `Name of New Compartment (Prefix)`, `Description for New Compartment`, `IAM Policy Name (Prefix)`, and `IAM Policy Description` if desired, and keep `Enable Delete for Compartment` and `Deploy IAM Policy` selected.
10. For this lab, we will deploy a subset of resources that can deployed using the Terraform code. In the `Select Resources` tile, ensure that only the checkboxes that correspond to the below indicated services are selected to deploy the corresponding services:

	- `Deploy Autonomous Database (ADB)`
	- `Deploy Compute Instance`
	- `Deploy Object Storage`
	- `Deploy Service Connector Hub (SCH)`
	- `Deploy Streaming`
	- `Deploy Virtual Cloud Network (VCN)`

11. Scroll to the Compute Instance tile. You will edit the following variables:
	1. **OCIR Username**: Your Oracle Cloud Infrastructure Registry (OCIR) username will be used to login to Docker for Function deployment to OCIR, and to OCI Applications for Functions.
		1. Click on the person icon at the top right of the page, and observe the name that appears under `Profile`. Your OCIR is the entire username, including any text and slash before your email address. For example, if your user is part of the `Default` identity domain, your OCIR would be similar to `Default/john.doe@mydomain.com`. Enter this username into the `OCIR Username` field.
	2. **OCIR Password**: This value will be used to authenticate into Docker for Function deployment to Oracle Cloud Infrastructure Registry (OCIR) and Applications.
		1. Duplicate the current browser tab. On the new tab, click the person icon. Then, from the dropdown menu, click `My profile`.
		2. Scroll down on your profile page, and click `Auth tokens` on the left side of the screen. Then, click `Generate token`. Supply a description you will recognize, such as `streaming lab`, and then click `Generate token`.
		3. Copy the generated token to your clipboard by clicking `Copy`, then navigate to the original browser tab where you are editing the stack configuration detials and paste the copied token into the `OCIR Password` field. Then, navigate back to the new browser tab and click `Close`. Note that if you close out of the window before copying the token, it will be necessary to generate a new token, for which you may refer to the previous step.
	3. **SSH Public Key Pair**: You will generate an SSH key pair, which you will later use to access your compute instance.
		1. On the new browser tab, click Developer Tools, marked with `<>`, and open Cloud Shell.
		2. Feel free to skip or follow the Cloud Shell tutorial. Note your ability to minimize, maximize, and restore the Cloud Shell window as is convenient for intermittent interaction with the OCI Console UI.
		3. On the Cloud Shell command-line interface (CLI), run the following command to generate an SSH key pair. Then, press `Enter` after each prompt to proceed with default settings for the key pair. The default settings result in save locations of `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` for the private and public SSH keys, respectively, and no passphrase required to use the SSH key pair. Move on to the next step once you see the key's randomart image displayed.
			
			```
			ssh-keygen -t rsa
			```
		4. Print the contents of the public SSH key file to the CLI output console by running the following command.
			
			```
			cat ~/.ssh/id_rsa.pub
			```
		5. Copy and paste the printed contents into the `Public SSH Key` field on your original Stack creation browser tab. The key starts with `ssh-rsa` and ends with `<username>@...`.
12. <i>Optional</i>: In the `ADB Admin Password` field, the default password for the Autonomous JSON Database is `Streaming!2345`. If you would like to change this password to something else, replace the default password and remember your password for use later on.
13. The remaining details on the `Configure Variables` page can be left as their default values or updated to fit your needs.
14. When you are finished editing your variables in the `Configure Variables` section, click `Next` to proceed to the `Review` section.
15. Select the checkbox for `Run Apply`, and click `Create`. You can monitor the deployment by monitoring the `Logs` window.
16. Once the selected resources have been provisioned, click `Job resources` to open a page that shows details about the resources that were provisioned.
17. Copy the name of the deployed compartment to your clipboard for later use. You can find the name of the compartment under the `Name` column, where the value under `Type` appears as `oci_identity_compartment`.
18. Keep this browser tab open, as we will refer to this page later in this lab. Proceed with the next section using either the browser tab you have duplicated earlier in this section, or another browser tab that where you are logged into the OCI Console.
	\
	\
	<b>Congratulations! You've successfully deployed a custom stack of OCI resources using Resource Manager!</b>
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>

### Configure AJD for Stream Processing
In this section, you will set up the following items in your Autonomous JSON Database (AJD) instance:
- <b>JSON Collection</b>: This object will store data points from a data stream in JSON format.
- <b>Database View</b>: This object will contain a virtual table that enables querying of the JSON data as if it were a relational table.

1. In your OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `adb` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Autonomous JSON Database`.
2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
3. Click on the hyperlinked Database object you created.
4. Click `Database actions`, then select `View all database actions`. Note that you may need to allow pop-ups in your browser if launching the new page fails.
5. Enter your username and password for your AJD instance. For this lab, the default values are as indicated below. If you specified a custom password for your AJD instance, replace the default value with the custom value.
	\
	`Username`: `ADMIN`\
	`Password`: `Streaming!2345`
6. You have reached the `Database Actions` interface for your AJD instance. Click on the tile labeled `JSON`. Feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
7. Click `Create Collection`.
8. Enter `STREAMDATA` into the `Collection Name` field. Use upper-case letters for this name, because the endpoint address for the JSON Collection will incorporate this provided name, and it is case-sensitive.
9. Click `Create`.
10. Click on the hamburger menu in the upper left-hand side of the page, and click `SQL` under `Development`. Feel free to close the pop-up that warns that you are logged in as `ADMIN` user by clicking `X`. Also, feel free to skip the tutorial that is automatically launched. The tutorial can be skipped by clicking `X` on the pop-ups, and revisited by clicking on the binoculars icon on the upper right-hand side of the page.
11. Copy and paste the contents of [STREAM_PIPELINE.sql](./modules/sql/STREAM_PIPELINE.sql) from this repository into the editor. Highlight the PL/SQL code labeled `STREAMDATA_VIEW` (lines **3**-**23**) and click on the green `Run Statement` button. Next, highlight and run the first two lines of PL/SQL code labeled `STREAMDATA_LAST3_VIEW` (lines **27**-**28**).  This will create 2 database views, which use stored queries to create virtual tables that can be queried to return the JSON collection data in a relational format.  The `WHERE` clause (line **29**) will be added later on in the deployment process.
	\
	\
	<b>Congratulations! You've successfully configured your AJD for stream processing!</b>
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Run The Stream Pipeline
In this section, you will run the data stream from Cloud Shell to simulate streaming manufacturing data, then you will view the output from each step of the pipeline.

1. Find the public IP address of the compute instance from your Resource Manager deployment. To do this, navigate to the browser tab from which you deployed your Resource Manager Stack, and click `Outputs` on the left-hand side of the page. Clipboard-copy the public IP address under the `Value` column that corresponds to `compute_public_ip` under the `Key` column. If you don't see `Outputs`, look for the `Jobs` listing on the Stack Details page and click on the job that was run. `Outputs` should be visible on the job page. (You may need to change compartments to the parent compartment to view the Stack)
2. Click Developer Tools, marked with `<>`, and open Cloud Shell.
3. On the Cloud Shell command-line interface (CLI), run the following command to access the compute instance from your Resource Manager deployment, replacing `PUBLIC_IP_ADDRESS` with the value copied to your clipboard when running the following command in Cloud Shell.
	
	```
	ssh opc@PUBLIC_IP_ADDRESS
	```
4. If asked `Are you sure you want to continue connecting (yes/no)?`, type `yes` and hit enter.
5. Initiate the data stream by running the following command:

	```
	python /home/opc/OCI_Streaming_Pipeline-master/modules/compute/stream.py
	```
6. You should see output in the Cloud Shell displaying data points that are being sent into the stream. For example:

	```
	SENT: 1000
	SENT: 2000
	SENT: 3000 - 3000 msgs/sec
	SENT: 4000 - 4000 msgs/sec
	```
7. Minimize the Cloud Shell window, then navigate to your Stream on the `Streaming` page on OCI: 
	Click on the hamburger menu at the top-left of the webpage, and type `streaming` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Streaming` and `Messaging`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked Streaming object you created from your Resource Manager deployment.
8. Click `Load Messages`.  This will show the data points that have been ingested by the Streaming service.
9. Navigate to your Service Connector instance:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `service connector` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Service Connector Hub` and `Messaging`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked Service Connector object you created from your Resource Manager deployment.
10. Click `Metrics` from the Resources list on the left-hand side of the Service Connector page. This page provides detailed metrics about the Service Connector's data ingestion, Function task, and Object Storage target. About 1 minute after starting the data stream, you should see data populating under categories like `Bytes read from source`, `Bytes written to task`, and `Bytes written to target`. The source is the Streaming service, the task is the Function, and the target is Object Storage.
11. Navigate to your Object Storage Buckets:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `buckets` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Buckets`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked Bucket object that <b>does not</b> contain the word `raw`.
12. If you do not see data in this Bucket (.csv files in the csv_files folder), it can take a minute or two to populate. There is a refresh button under the `More Actions` menu in the middle of the page.  Periodically refresh the Bucket until you see populated data. This data is processed into CSV format and has been inserted into this Bucket by the Function triggered from the Service Connector.
\
\
If data has not populated within this Bucket after a minute or two, please review the [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline) section.
13. In the navigation ribbon on the top of the page, click `Object Storage` to return to the list of Buckets. Then click on the hyperlinked Bucket object that <b>does</b> contain the word `raw`.
14. If you do not see data in this Bucket, it can take a minute or two to populate. There is a refresh button under the `More Actions` menu in the middle of the page.  Periodically refresh the Bucket until you see populated data. This data is the unprocessed data that was transmitted to the Streaming service and has been inserted into this Bucket by the Service Connector.
\
\
If data has not populated within this Bucket after a minute or two, please review the [Troubleshooting and Logging when Running the Streaming Pipeline](#troubleshooting-and-logging-when-running-the-streaming-pipeline) section.
15. Navigate to your Autonomous JSON Database (AJD) instance:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `adb` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Autonomous JSON Database`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked Database object you created from your Resource Manager deployment.
16. Click `Database actions`, then select `View all database actions`. Note that you may need to allow pop-ups in your browser if launching the new page fails.
17. Enter your username and password for your AJD instance. For this lab, the default values are as indicated below. If you specified a custom password for your AJD instance, replace the default value with the custom value.
	\
	`Username`: `ADMIN`\
	`Password`: `Streaming!2345`
18. Click on the tile labeled `JSON`. In the query editor, leave the query as `{}` and click the green `Run Query` button to run the query. This will return all JSON elements in the JSON database. There is one JSON element for each data point that was tramsitted into the stream.
19. Click on the hamburger menu in the upper left-hand side of the page, and click `SQL` under `Development`.
20. Copy and paste the following PL/SQL query into the editor. This query returns the JSON data from `STREAMDATA`. The data points are contained within the `BLOB` element in each row.

	```
	-- Select all metadadata in JSON collection.  JSON payload data is within "BLOB"
	SELECT * FROM STREAMDATA;
	```
	Highlight the PL/SQL statement, then click on the round green `Run Statement` icon at the top of the editor to execute this statement.
21. Copy and paste the following PL/SQL query into the editor. This query returns the data in `STREAMDATA_VIEW`. This data has been converted to table format using the SQL query we configured earlier in this lab. Converting to table format allows the data to be easily queried for things like data visualization. `STREAMDATA_LAST3_VIEW` returns the same table format as `STREAMDATA_VIEW`, but we will configure this later on to only return the most recent 3 minutes of data.

	```
	-- Select all data in STREAMDATA_VIEW
	SELECT * FROM STREAMDATA_VIEW;
	```
	Highlight the PL/SQL statement, then click on the round green `Run Statement` icon at the top of the editor to execute this statement.
22. Now that you have viewd the active data pipleline, expand your Cloud Shell window and stop the data stream with the following keyboard command:
	```
	ctrl + c
	```
	If your ssh session has timed out, reconnect via ssh as described in step 3 of this section, then run the following command to locate the python script process ID:
	```
	ps -fA | grep python
	```
	Look for a row where the file path at the end of the row ends with `stream.py`. The process ID (PID) will be the number in the second column of that row. Replace `<PID>` with that number in the following command and hit enter to stop the stream:
	```
	kill -9 <PID>
	```
	\
	\
	<b>Congratulations! You've successfully run and viewed the output of the data stream!</b>
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Configure Oracle Analytics Cloud
In this section, you will deploy and configure Oracle Analytics Cloud (OAC) to visualize the data stream.

1. Return to a browser tab where you can access the main OCI Console. Click on the hamburger menu at the top-left of the webpage, and type `analytics` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Analytics Cloud` and `Analytics`.
2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
3. Click `Create Instance`.
4. Note that the Oracle Analytic Cloud (OAC) instance requires a name, and that all other values can be left as default for this lab. Use `streamingoac` as a prefix specific to this lab, and as a suffix, add the unique string associated with your deployment. This unique string is visible at the end of your compartment name on the left side of the page.
5. Click `Create`. OAC could take around 10 minutes to provision.
6. While the OAC instance is provisioning, navigate back to the Autonomous JSON Database (AJD) page on OCI: 
	Click on the hamburger menu at the top-left of the webpage, and type `adb` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Autonomous JSON Database`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked AJD object you created from your Resource Manager deployment.
7. Click `Database connection`, then click `Download wallet`. Enter a password for the wallet. This password may be of your choosing. For simplicity, you may choose `Streaming!2345`, which is the password provided in this lab for the `admin` user in AJD. Then click `Download`. The .zip file that gets downloaded to your local machine is the wallet, and will be required to connect OAC to AJD. Click `Close` on the `Database connection` window.
8. Return to the OAC page:
	\
	Click on the hamburger menu at the top-left of the webpage, and type `analytics` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Analytics Cloud` and `Analytics`. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page. Click on the hyperlinked OAC object you created.
9. If the OAC instance does not have a `State` of `Active`, wait for it to finish provisioning.
10. Once the instance is active, click `Analytics Home Page` to open Oracle Analytics Cloud.
11. Click `Create` in the top-right corner of the OAC home page, then click `Connection`. Select `Oracle Autonomous Transaction Processing` to connect to your Autonomous JSON Database.
12. Enter a name for the connection. For this lab, use `streaming_ajd_conn`, as this name is referred to later in this lab. Then, drag and drop the downloaded wallet file into the `Client Credentials` box. The `Description` field is optional. Leave the remaining fields unchanged.
13. The `Username` and `Password` sections are referencing the AJD instance, so enter `admin` for the username, and `Streaming!2345` for the password, or your own custom password if you chose to set a custom password.
14. Click `Save`. The connection will validate, and then save. If the connection fails, double check your username and password for the database.
	\
	<i>Note: The password to be supplied here is the password for the `admin` user in AJD, which is `Streaming!2345`, or your own custom password if you chose to set a custom password.</i>
15. Click `Create` in the top-right corner of the OAC home page, then click `Dataset`. Select the database connection you just created, named `streaming_ajd_conn`.
16. On the left-hand side of the page, expand the `Schemas` dropdown menu by clicking the arrow next to `Schemas`. Then, expand the dropdown menu of the `ADMIN` schema that appears on the `Schemas` dropdown menu. Drag and drop `STREAMDATA_LAST3_VIEW` into the main canvas area to add it to the dataset. This will load a preview of the data.
17. Convert `KEY`, `PARTITION`, `OFFSET`, and `EQUIPMENT_ID` to attributes. To do this, click on the pound sign next to each column's name and select `Attribute`.
18. Set the aggregation for `VIBRATION_AMPLITUDE`, `VIBRATION_FREQUENCY`, `TEMPERATURE`, and `HUMIDITY` to average. To do this, select the `STREAMDATA_LAST3_VIEW` tab at the bottom of the screen and then select the `VIBRATION_AMPLITUDE` column. There will be a series of configuration settings for that column in the bottom left corner of the screen. Click `Sum` in the `Aggregation` setting, and change the value to `Average`. Repeat this process for each of the columns listed in this step.
19. Click the `Save` icon in the top-right corner of the page, which appears as an image of a hard-drive. Provide a name for the dataset. For this lab, use `streaming_dataset`, as this name is referred to later in this lab. The `Description` field is optional. Click `OK`.
20. Click the `Back` arrow in the top-left corner of the page to return to the OAC home page.
21. In another browser tab, navigate back to the SQL Editor in `Autonomous Data Warehouse` `Database actions`.  In the provided [STREAM_PIPELINE.sql](./modules/sql/STREAM_PIPELINE.sql), uncomment the third line of `STREAMDATA_LAST3_VIEW` (line **29**) by removing the leading dashes and space. Highlight and run all three lines of PL/SQL for `STREAMDATA_LAST3_VIEW` including the newly uncommented `WHERE` clause (lines **27**-**29**). Return to the browser tab with `Analytics Cloud` after executing this code.
22. On the OAC home page, click `Create` in the top-right corner of the page, then click `Workbook`. In the popup titled `Add Data`, Select the dataset you just created, named `streaming_dataset`, then click `Add to Workbook`. For now, close the `Auto Insights` window on the right-hand side of the page by clicking on the light-bulb icon.
23. In the data pane on the left side of the screen, click the arrow next to `TIMESTAMP` to expand that data field. Hold `command` if using a Mac or `control` if using a PC, then select `Second` and `VIBRATION_AMPLITUDE` from the data pane. Drag and drop these data elements onto the canvas. This will create a line chart.
24. Select `VIBRATION_FREQUENCY`, `TEMPERATURE`, and `HUMIDITY` from the data pane, and drag and drop these data elements in the `Values (Y-Axis)` section of the visualization pane just to the right of the data pane. Be sure not to drop the data elements on top of `VIBRATION_AMPLITUDE`, as that will add the new elements in place of the existing data, rather than in addition to the existing data. This data may take a moment to load. When the database icon on the top right corner of the canvas has a spinning circle around it, the data is still loading.
25. Right click on the Canvas tab on the bottom of the page labeled `Canvas 1` and select `Canvas Properties`.
26. Click on `Disabled` next to `Auto Refresh Data` to switch it to `Enabled`. Change the value from `30` to `10`, and click `OK`. This will refresh the canvas every 10 seconds. <i>You may need to scroll down in the properties menu to view the `OK` button</i>
27. Click the `Refresh Data` button in the top-right toolbar. It looks like a white play button with an arrow circling around it. This will start the auto refresh process.
28. Click the `Save` icon in the top-right corner of the page. Provide a name for the workbook and click `Save`.
29. Click the `Preview` button in the top-right toolbar to view the dashboard as an end user. It looks like an outline of a play button. Click the `Refresh Data` button in the toolbar to start the auto refresh process in this view.
\
\
<b>Congratulations! You are now visualizing the output of your completed streaming pipeline!</b>

![OAC Workbook](/images/oac_workbook.png)
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Stop the Data Stream

To stop the data stream, navigate to the page with the Cloud Shell where you are logged into your compute instance, running `stream.py`. Click within the Cloud Shell window, and press `ctrl` + `c` to stop the script. 
\
\
<b>Thank you, and congratulations on completing this workshop!</b>
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
## Additional Steps

### Data Cleanup
The following steps describe the process of clearing the data out of the pipeline. This can be useful when you want to start a fresh stream of data without any residual data from previous pipeline usage. This process involves clearing the JSON collection and clearing both Object Storage Buckets.
- [Clearing the JSON Collection](#clearing-the-json-collection)
- [Clearing the Object Storage Buckets](#clearing-the-object-storage-buckets)
#### Clearing the JSON Collection

1. Navigate to Autonomous JSON Database (AJD) Database Actions:
	1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `adb` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Autonomous JSON Database`.
	2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
	3. Click on the hyperlinked Database object you created.
	4. Click `Database actions`, and enter your username and password for your AJD instance if prompted.
2. Click on the tile labeled `JSON`. If you are still in the SQL editor from earlier, you can navigae back to the main Database Actions menu by clicking the Oracle logo in the top left corner of the page.
3. Click the trash can icon on the top left in the toolbar above the JSON query editor. This button is labeled `Delete All Documents in the list` when hovering over it.
4. Click `OK` to confirm.
#### Clearing the Object Storage Buckets

1. Navigate to Object Storage:
	1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `buckets` into the search field but do not hit enter. Click the listing that appears on the page that contains the word `Buckets`.
	2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
2. For each Bucket:
	1. Click on the hyperlinked Bucket name
	2. Locate the row in the `Objects` window for the highest level folder in the Bucket, and click on the three vertically-oriented dots on the far right-hand side of the row.
	3. Click `Delete Folder`.
	4. Enter the folder name into the confirmation window as prompted, and click `Delete`. This may take a moment if there is a large quantity of data in the bucket.

After these steps, the JSON collection and Object Storage Bucktes are empty and ready to recieve new stream data.
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Resource Cleanup
The following steps walk through the process of deprovisioning the resources that were deployed in this lab. This will terminate billing for infrastructure resources, and re-allocate capacity for other projects.

1. [Deprovision Oracle Analytics Cloud (OAC) instance](#deprovision-oracle-analytics-cloud-oac-instance)
2. [Deprovision Application](#deprovision-application)
3. [Remove Cloud Shell artifacts](#remove-cloud-shell-artifacts)
4. [Deprovision Infrastructure Deployed via Resource Manager Stack](#deprovision-infrastructure-deployed-via-resource-manager-stack)
5. [Deprovision Resource Manager Stack instance](#deprovision-resource-manager-stack-instance)

#### Deprovision Oracle Analytics Cloud (OAC) instance

1. Navigate to OAC: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `analytics` into the search field but do not hit enter. Click the listing that appears on the page that contains the word `Analytics Cloud` and `Analytics`.
2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
3. Click on the hyperlinked OAC instance name.
4. Click on the `More actions` button, and click `Delete` from the dropdown menu that appears. Then, click `Delete`.

#### Deprovision Application
Deprovisioning the Application will deprovision the associated Function as well.

1. Navigate to Application: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `functions` but do not hit enter. Click the listing that appears on the page that contains the word `Applications` and `Functions`.
2. Ensure that the compartment that was deployed from the Resource Manager Stack is selected in the `Compartment` dropdown on the left side of the page.
3. Click on the hyperlinked Application instance name.
4. Click on the `Delete` button. On the confirmation pop-up window, fill in the text box as prompted and click `Delete`.

#### Remove Cloud Shell artifacts
These steps will walk through the process of removing the folders, files, and persisting environment variables set up on Cloud Shell for this project.

1. Navigate to Cloud Shell: Click on the `Developer tools` icon on the upper right-hand side of the page, and then click `Cloud Shell`.
2. Remove your SSH key files.

	```
	rm ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
	```
3. Exit out of Cloud Shell using the `X` icon.

#### Deprovision Infrastructure Deployed via Resource Manager Stack
These steps will walk through the process of performing the `Destroy` operation in the Resource Manager Stack instance to deprovision the resources that were deployed from running the `Apply` action from the same Resource Manager Stack instance.

1. Navigate to Resource Manager: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `stacks` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
2. <b>Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.</b>
3. Click on the hyperlinked Resource Manager Stack object you created for this lab.
4. Click on the red `Destroy` button at the top of the page.
5. Notice the caution message shown on the pane that appears. Then, click `Destroy`. You can monitor the deprovisioning process by monitoring the `Logs` window.
\
\
If an error is encountered and the Destroy job reaches the `Failed` state as a result, please review the [Troubleshooting Resource Manager Cleanup](#troubleshooting-resource-manager-cleanup) section.

#### Deprovision Resource Manager Stack instance
These steps will walk through the process of deprovisioning the Resource Manager Stack instance itself. As a best practice, ensure that the resources that were deployed using the Resource Manager Stack have been deprovisioned using the `Destroy` operation from the Resource Manager Stack page. This will eliminate the need to deprovision each resource individually.

1. Navigate to Resource Manager: In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `stacks` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Stacks` and `Resource Manager`.
2. Click on the dropdown under `Compartment`, and select the compartment where you created your Resource Manager Stack object. If your tenancy environment is new, this will be your root-level compartment.
3. Click on the hyperlinked Resource Manager Stack object you created for this lab.
4. Ensure that the resources that were provisioned using the Resource Manager Stack have been deprovisioned using the `Destroy` operation: Locate the `Jobs` section in the middle of the page. Ensure that the `Type` and `State` values of the top-most (i.e. most recent) job read `Destroy` and `Succeeded`, respectively.
5. Click on the `More actions` button, and click `Delete stack` from the dropdown menu that appears. Then, click `Delete`.
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Troubleshooting and Logging when Running the Streaming Pipeline

If the stream pipeline is not functioning as expected, follow these steps to enable logging for the function. These logs can provide additional information about certain points of failure.

1. Navigate to the hamburger menu at the top-left of the webpage, and type `functions` into the search field but do not hit enter. Click the listing that appears on the page that contains the words `Applications` and `Functions`.
2. Ensure that the  compartment that was deployed from the Resource Manager Stack is selected in the`Compartment` dropdown on the left side of th Stack.
3. Click on the hyperlinked Application object you created, called `streaming_app`.
4. Click `Logs` in the `Resources` menu on the left side of the Application page.
5. Locate the `Function Invocation Logs` row in the `Logs` window in the middle of the page, and click on the switch icon in the `Enable Log` column.
6. Ensure that the correct compartment is selected, and leave the other options as default. This will auto-create the default Log Group and provide a standard name and retention policy. Click `Enable Log`.
7. Click the hyperlined log name from the `Log Name` column to view the Log.
8. Run the stream, and refresh this Log page to view the output of the function. Basic error messages have been included in the function code to help identify where the function is failing.
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
### Troubleshooting Resource Manager Cleanup
If an error is encountered and the Destroy job reaches the `Failed` state as a result, identify which scenario listed below best describes the error encountered, and follow the steps associated with that scenario.

- [Compartment being reported as in the `ACTIVE` state](#compartment-being-reported-as-in-the-active-state)
- [Some other resource is indicated in the error message](#some-other-resource-is-indicated-in-the-error-message)

#### Compartment being reported as in the `ACTIVE` state
This may be due to the presence of resources that have been provisioned within the compartment that are not associated with the Resource Manager Stack. The compartment will remain in the `ACTIVE` state so long as there are any resources within it, as a measure to protect resources from being unintentionally deleted. The steps to ensure that there are no resources in the compartment are indicated below.

1. In your main OCI Console, navigate to the hamburger menu at the top-left of the webpage, and type `compartments` into the search field but do not hit enter. Click the listing that appears on the page that contains the word `Compartments` and `Identity`.
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
\
<sub>[Back to top](#oci-streaming-pipeline)</sub>
