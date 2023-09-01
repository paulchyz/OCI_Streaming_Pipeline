# Oracle Cloud Infrastructure Streaming Pipeline Function

import io
import json
import logging
import base64
import datetime
from pyexpat import model
import pandas as pd
import oci.object_storage
import requests
import oci
from oci.signer import Signer
from oci.data_science import DataScienceClient

# Configure parameters, load stream data, call ETL function
def handler(ctx, data: io.BytesIO=None):
    try:
        cfg = ctx.Config()
        json_collection_name = cfg['json-collection-name']
        processed_bucket = cfg['streaming-bucket-processed']
        ordsbaseurl = cfg['ords-base-url']
        schema = cfg['db-schema']
        dbuser = cfg['db-user']
        dbpwd = cfg['dbpwd-cipher']
        modelendpoint = cfg['model-endpoint']
        client, namespace = config_object_store()
        auth = oci.auth.signers.get_resource_principals_signer()
        dsc = DataScienceClient(config={}, signer=auth)
        src_objects = json.loads(data.getvalue().decode('utf-8'))
        output = execute_etl(client, namespace, processed_bucket, src_objects, ordsbaseurl, schema, dbuser, dbpwd, json_collection_name, modelendpoint, auth)
        return output

    except (Exception, ValueError) as ex:
        logging.getLogger().info('Top Level Error: ' + str(ex))
        return None

# Configure object storage credentials
def config_object_store():
    signer = oci.auth.signers.get_resource_principals_signer()
    client = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
    namespace = client.get_namespace().data
    return client, namespace

# Call required functions for ETL
def execute_etl(client, namespace, dst_bucket, src_objects, ordsbaseurl, schema, dbuser, dbpwd, json_collection_name, modelendpoint, auth):
    decoded_objects = decode_objects(src_objects)
    csv_data = to_csv(decoded_objects, modelendpoint, auth)
    obj_name = 'csv_data/' + datetime.datetime.now().strftime('%Y%m%d%H%M%S%f') + '.csv'
    resp = put_object(client, namespace, dst_bucket, obj_name, csv_data)
    #ML
    mlresults_df = invoke_model(decoded_objects, modelendpoint, auth)
    decoded_objects[0]['value'] = json.loads(mlresults_df.to_json(orient='records'))
    insert_status = load_data(ordsbaseurl, schema, dbuser, dbpwd, decoded_objects, json_collection_name)
    return decoded_objects

# Decode stream data
def decode_objects(src_objects):
    for obj in src_objects:
        obj['key'] = base64.b64decode(obj['key']).decode('utf-8')
        obj['value'] = json.loads(base64.b64decode(obj['value']).decode('utf-8'))
    return src_objects

# Convert decoded data into JSON format
def to_csv(decoded_objects, modelendpoint, auth):
    modelresults_df = invoke_model(decoded_objects, modelendpoint, auth)
    csv_data = modelresults_df.to_csv(index=False)
    return csv_data

# Load CSV data into object storage
def put_object(client, namespace, dst_bucket, obj_name, data):
    try:
        output = client.put_object(namespace_name=namespace, bucket_name=dst_bucket, object_name=obj_name, put_object_body=data, content_type="text/csv")
    except (Exception, ValueError) as ex:
        logging.getLogger().error(str(ex))
    return output

# Load JSON data into ADW JSON collection
def load_data(ordsbaseurl, schema, dbuser, dbpwd, decoded_objects, json_collection_name):
    insert_status = soda_insert(ordsbaseurl, schema, dbuser, dbpwd, decoded_objects, json_collection_name)

    if "id" in insert_status["items"][0]:
        print("INFO - Successfully inserted document ID " + insert_status["items"][0]["id"], flush=True)
    else:
        raise SystemExit("Error while inserting: " + insert_status)
    return insert_status

# SODA call to perform DB insert
def soda_insert(ordsbaseurl, schema, dbuser, dbpwd, obj, json_collection_name):
    auth=(dbuser, dbpwd)
    sodaurl = ordsbaseurl + schema + '/soda/latest/'
    collectionurl = sodaurl + json_collection_name
    headers = {'Content-Type': 'application/json'}
    r = requests.post(collectionurl, auth=auth, headers=headers, data=json.dumps(obj))
    r_json = {}
    try:
        r_json = json.loads(r.text)
    except ValueError as e:
        print('SODA Insert Error: ' + str(e), flush=True)
        raise
    return r_json

def invoke_model(decoded_objects, modelendpoint, auth):
    #Resource Principal 
    data = pd.json_normalize(decoded_objects, record_path=['value'])
    #clean data (only select columns we need, add const column (needed for ML))
    df = data[['vibration_amplitude', 'vibration_frequency','temperature','humidity']]
    df.insert(loc=0, column='const', value=1)
    #finalize payload df
    payload_list = df.values.tolist()
    #infer the model
    body = payload_list
    headers = {} # header goes here
    output = requests.post(modelendpoint, json=body, auth=auth, headers=headers).json()
    predictions = [ '%.1f' % elem for elem in output['prediction'] ]
    #add result list to the original dataset
    data['Prediction'] = predictions
    return data

