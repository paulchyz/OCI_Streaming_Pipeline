# Oracle Cloud Infrastructure Streaming Pipeline Function
# Created by Paul Chyz on 1/25/2022

import io
import json
import logging
import base64
import datetime
import pandas as pd
import oci.object_storage
import requests

def handler(ctx, data: io.BytesIO=None):
    try:
        cfg = ctx.Config()
        processed_bucket = cfg['streaming-bucket-processed']
        ordsbaseurl = cfg['ords-base-url']
        schema = cfg['db-schema']
        dbuser = cfg['db-user']
        dbpwd = cfg['dbpwd-cipher']
        client, namespace = config_object_store()
        src_objects = json.loads(data.getvalue().decode('utf-8'))
        output = execute_etl(client, namespace, processed_bucket, src_objects, ordsbaseurl, schema, dbuser, dbpwd)
        
    except (Exception, ValueError) as ex:
        logging.getLogger().info('error: ' + str(ex))
    return output

def config_object_store():
    signer = oci.auth.signers.get_resource_principals_signer()
    client = oci.object_storage.ObjectStorageClient(config={}, signer=signer)
    namespace = client.get_namespace().data
    return client, namespace

def execute_etl(client, namespace, dst_bucket, src_objects, ordsbaseurl, schema, dbuser, dbpwd):
    decoded_objects = decode_objects(src_objects)
    csv_data = to_csv(decoded_objects)
    obj_name = 'csv_data/' + datetime.datetime.now().strftime('%Y%m%d%H%M%S%f') + '.csv'
    resp = put_object(client, namespace, dst_bucket, obj_name, csv_data)
    load_resp = load_data(ordsbaseurl, schema, dbuser, dbpwd, decoded_objects)
    return decoded_objects

def decode_objects(src_objects):
    for obj in src_objects:
            obj['key'] = base64.b64decode(obj['key']).decode('utf-8')
            obj['value'] = json.loads(base64.b64decode(obj['value']).decode('utf-8'))
    return src_objects

def to_csv(data_list):
    for item in data_list:
        for key in item['value'][0]:
            item[key] = item['value'][0][key]
        del item['value']

    df = pd.json_normalize(data_list)
    csv_data = df.to_csv(index=False)
    return csv_data

def put_object(client, namespace, dst_bucket, obj_name, data):
    try:
        output = client.put_object(namespace_name=namespace, bucket_name=dst_bucket, object_name=obj_name, put_object_body=data, content_type="text/csv")
    except (Exception, ValueError) as ex:
        logging.getLogger().error(str(ex))
        return {"Error Response": str(ex)}
    return output

def load_data(ordsbaseurl, schema, dbuser, dbpwd, decoded_objects):
    for obj in decoded_objects:
        insert_status = soda_insert(ordsbaseurl, schema, dbuser, dbpwd, obj)
        if "id" in insert_status["items"][0]:
            print("INFO - Successfully inserted document ID " + insert_status["items"][0]["id"], flush=True)
        else:
            raise SystemExit("Error while inserting: " + insert_status)
    return insert_status

def soda_insert(ordsbaseurl, schema, dbuser, dbpwd, obj):
    auth=(dbuser, dbpwd)
    sodaurl = ordsbaseurl + schema + '/soda/latest/'
    collectionurl = sodaurl + "streamdata"
    headers = {'Content-Type': 'application/json'}
    r = requests.post(collectionurl, auth=auth, headers=headers, data=json.dumps(obj))
    r_json = {}
    try:
        r_json = json.loads(r.text)
    except ValueError as e:
        print(r.text, flush=True)
        raise
    return r_json

def update_tables(ordsbaseurl, schema, dbuser, dbpwd, procedure):
    auth=(dbuser, dbpwd)
    procedure_url = ordsbaseurl + schema + '/' + procedure + '/'
    r = requests.post(procedure_url, auth=auth)
    r_json = {}
    try:
        r_json = json.loads(r.text)
    except ValueError as e:
        print(r.text, flush=True)
        raise
    return r_json
