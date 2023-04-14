# Oracle Cloud Infrastructure IoT Streaming Simulation Script
# Created by Paul Chyz on 5/19/2021

import oci
import json
import time
import datetime
import random
from base64 import b64encode
import os

config = oci.config.from_file(file_location=os.environ['STREAMING_OCI_CONFIG_FILE_LOCATION'])
sid = os.environ['STREAMING_STREAM_OCID']
message_endpoint = os.environ['STREAMING_MESSAGES_ENDPOINT']

amp_odds = .001
freq_odds = .001
temp_odds = .001
hum_odds = .001

amp_flag = False
freq_flag = False
temp_flag = False
hum_flag = False

amp_count = 0
freq_count = 0
temp_count = 0
hum_count = 0

base_amp = float(250)
base_freq = float(1000)
base_temp = float(60)
base_hum = float(30)

equipment_id = 1234
outlier_count = 500

message_count = 0

# Initialize service client with default config file
streaming_client = oci.streaming.StreamClient(config, message_endpoint)

while True:
    payload_list = []
    for i in range(1000):
        # AMPLITUDE
        if (amp_flag == False) and (random.random() < amp_odds):
            amp_flag = True

        if (amp_flag == True) and amp_count < outlier_count:
            amp_count = amp_count + 1
            vibration_amplitude = round(base_amp * round(random.uniform(1.5, 1.8), 3), 2)
            #print ('AMPLITUDE OUTLIER')
        else:
            amp_count = 0
            amp_flag = False
            vibration_amplitude = round(base_amp * round(random.uniform(0.9, 1.1), 3), 2)

        # FREQUENCY
        if (freq_flag == False) and (random.random() < freq_odds):
            freq_flag = True

        if (freq_flag == True) and freq_count < outlier_count:
            freq_count = freq_count + 1
            vibration_frequency = round(base_freq * round(random.uniform(1.5, 1.8), 3), 2)
            #print ('FREQUENCY OUTLIER')
        else:
            freq_count = 0
            freq_flag = False
            vibration_frequency = round(base_freq * round(random.uniform(0.9, 1.1), 3), 2)

        # TEMPURATURE
        if (temp_flag == False) and (random.random() < temp_odds):
            temp_flag = True

        if (temp_flag == True) and temp_count < outlier_count:
            temp_count = temp_count + 1
            tempurature = round(base_temp * round(random.uniform(1.5, 1.8), 3), 2)
            #print ('TEMPERATURE OUTLIER')
        else:
            temp_count = 0
            temp_flag = False
            tempurature = round(base_temp * round(random.uniform(0.9, 1.1), 3), 2)

        # HUMIDITY
        if (hum_flag == False) and (random.random() < hum_odds):
            hum_flag = True

        if (hum_flag == True) and hum_count < outlier_count:
            hum_count = hum_count + 1
            humidity = round(base_hum * round(random.uniform(1.5, 1.8), 3), 2)
            #print ('HUMIDITY OUTLIER')
        else:
            hum_count = 0
            hum_flag = False
            humidity = round(base_hum * round(random.uniform(0.9, 1.1), 3), 2)

        data = {"timestamp": str(datetime.datetime.now()), "equipment_id": equipment_id, "vibration_amplitude": vibration_amplitude, "vibration_frequency": vibration_frequency, "temperature": tempurature, "humidity": humidity}
        payload_list.append(data)

    payload = json.dumps(payload_list)
    encoded_value = b64encode(payload.encode()).decode()
    timestamp = str(datetime.datetime.now())
    encoded_key = b64encode(timestamp.encode()).decode()

    # Send the message request to streaming service
    mesgs=[oci.streaming.models.PutMessagesDetailsEntry(value=encoded_value,key=encoded_key)]
    put_mesgs_dets=oci.streaming.models.PutMessagesDetails(messages=mesgs)
    put_messages_response = streaming_client.put_messages(stream_id=sid, put_messages_details=put_mesgs_dets)

    # Get the data from response
    if (put_messages_response.data.failures) == 0:
        message_count = message_count + len(payload_list)
        print ('SENT: ' + str(message_count))
    else:
        print ('MESSAGE FAILURE: ' + str(put_messages_response.data.failures))

    time.sleep(1)