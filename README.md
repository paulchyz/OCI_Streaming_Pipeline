# OCI Streaming Pipeline

This document provides instructions for deployment and configuration of a cloud-native streaming and anaylsis pipeline using Oracle Cloud Infrastructure.

## Introduction

Data streaming is a powerful tool capable of accelerating business processes and facilitating real-time decision making across a wide variety of industries and use cases. There are many ways to implement streaming technology, and each solution offers different benefits and drawbacks. The approach documented below is a cloud-native, low-code approach to streaming, covering the complete data lifecycle from ingestion to analysis. This will enable organizations to implement a complete streaming pipeline quickly without the need for a highly specialized team of developers. 

### Objective

This repository leverages Oracle Cloud Infrasturcture's array of services to deploy a low-code end-to-end streaming pipeline.  The included Terraform Stack handles resource deployment, and additional configuration steps are documented below.  The resulting architecture is a cloud-native streaming pipeline, capable of data ingestion, processing, strorage, and analysis.

### System Architecture

![System Architecture](/images/system_architecture.png)

### Included Resources

* **Oracle Compute Intance**
  * The compute instance hosts a data generation script and serves as the source for the demo data stream.
* **Oracle Streaming**
  * Oracle Streaming ingests the data stream from the Oracle compute instance or any other external source in real time.  This is the first stage in the pipeline.
* **Oracle Service Connector Hub**
  * Service Connector Hub is connected to Oracle Streaming.  It is responsible for passing the data from Oracle Streaming to Oracle Functions, triggering Oracle Functions for data processing, and passing the unprocessed data to Object Storage.
* **Oracle Functions**
  * Oracle Functions contains the data cleansing script and is triggered by Oracle Service Connector Hub.  Upon execution, the function ingests, decodes, parses, formats, and delivers the data to Object Storage and the Autonomous Data Warehouse.
* **Oracle Object Storage**
  * Object Storage hosts two buckets for data staging.  One bucket receives the processed data from Oracle Functions, and the other recieves the raw, unprocessed data from Oracle Service Connector Hub.
* **Oracle Autonomous Data Warehouse (ADW)**
  * The Autonomous Data Warehouse serves as the converged database for the processed data, storing the data in both a JSON database and in a relational database.
* **Oracle Analytics Cloud (OAC)**
  * Oracle Analytics Cloud is the final stage of the pipeline, enabling the creation of data visualizations that end users can use to analyze the data stream.
* **Oracle Virtual Cloud Network (VCN) & Subnet**
  * The Oracle Virtual Cloud Network and Subnet make up the network that contains the pipeline's Oracle Cloud Infrastructure resources.

### Prerequisites

* An Oracle Cloud Infrastructure tenancy or trial.

## Terraform Stack Deployment

Follow these steps to deploy the streaming pipeline Terraform Stack on OCI. Before beginning, ensure that you have satisfied the prerequisites listed above.

### Preparation

### Installation

### Configuration

### Manual Configuration

## Running the Streaming Pipeline

Follow these steps to stream data into the streaming pipeline and to analyze the output.

### Starting the Data Stream

### Viewing output in OCI

### Viewing output in ADW

### Viewing output in OAC

### Viewing output in Oracle Data Science

### References
