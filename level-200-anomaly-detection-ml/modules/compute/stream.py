import oci
import json
import time
import datetime
import random
from base64 import b64encode
import os

#config = oci.config.from_file(file_location=os.environ['STREAMING_OCI_CONFIG_FILE_LOCATION'])
sid = os.environ['STREAMING_STREAM_OCID']
message_endpoint = os.environ['STREAMING_MESSAGES_ENDPOINT']

amp_odds = 0.006
freq_odds = 0.015
temp_odds = 0.009
temp_odds_high = temp_odds*3
hum_odds = 0.006

# Length of anomalies (number of 1000 data point bursts)
anomaly_length = 10

base_amp = float(250)
base_freq = float(1000)
base_temp = float(60)
base_hum = float(30)

noise_range = 0.2
normal_upper_bound = 1 + (noise_range*0.5)
normal_lower_bound = 1 - (noise_range*0.5)
anomaly_lower_bound = normal_upper_bound + 0.01 
anomaly_upper_bound = normal_upper_bound + noise_range

equipment_ids = [101, 102, 103]
flags = []
for id in equipment_ids:
     flags.append([0, 0, 0, 0])

message_count = 0

# Initialize service client with instance principal signer
signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
streaming_client = oci.streaming.StreamClient(config={}, service_endpoint=message_endpoint, signer=signer)

start_time = datetime.datetime.now()

while True:
    x = 0
    offset = []

    # Create 4 data value offsets
    for i in range(4):
        offset.append((normal_upper_bound - normal_lower_bound) * random.uniform(-0.5, 0.5))

    # Loop through equipment IDs   
    for id in equipment_ids:
        payload_list = []

        # Determine anomaly states
        # AMPLITUDE
        if (flags[x][0] == 0):
            if (random.random() < amp_odds):
                flags[x][0] = 1
        elif (flags[x][0] >= anomaly_length):
             flags[x][0] = 0
        else:
             flags[x][0] = flags[x][0] + 1

        # FREQUENCY
        if (flags[x][1] == 0):
            if (random.random() < freq_odds):
                flags[x][1] = 1
        elif (flags[x][1] >= anomaly_length):
             flags[x][1] = 0
        else:
             flags[x][1] = flags[x][1] + 1

        # TEMPERATURE
        if (flags[x][2] == 0):
            # Increase anomaly probability if vibration amplitude is anomalous
            if (flags[x][1] > 0):
                if (random.random() < (temp_odds_high)):
                    flags[x][2] = 1
            else:
                if (random.random() < temp_odds):
                    flags[x][2] = 1
        elif (flags[x][2] >= anomaly_length):
             flags[x][2] = 0
        else:
             flags[x][2] = flags[x][2] + 1

        # HUMIDITY
        if (flags[x][3] == 0):
            if (random.random() < hum_odds):
                flags[x][3] = 1
        elif (flags[x][3] >= anomaly_length):
             flags[x][3] = 0
        else:
             flags[x][3] = flags[x][3] + 1

        # Generate 1000 data points for an equipment ID
        for i in range(1000):
            # AMPLITUDE
            if (flags[x][0] >= 1):
                vibration_amplitude = round(base_amp * (round(random.uniform(anomaly_lower_bound, anomaly_upper_bound), 3) + offset[0]), 2)
            else:
                vibration_amplitude = round(base_amp * (round(random.uniform(normal_lower_bound, normal_upper_bound), 3) + offset[0]), 2)

            # FREQUENCY
            if (flags[x][1] >= 1):
                vibration_frequency = round(base_freq * (round(random.uniform(anomaly_lower_bound, anomaly_upper_bound), 3) + offset[1]), 2)
            else:
                vibration_frequency = round(base_freq * (round(random.uniform(normal_lower_bound, normal_upper_bound), 3) + offset[1]), 2)

            # TEMPURATURE
            if (flags[x][2] >= 1):
                tempurature = round(base_temp * (round(random.uniform(anomaly_lower_bound, anomaly_upper_bound), 3) + offset[2]), 2)
            else:
                tempurature = round(base_temp * (round(random.uniform(normal_lower_bound, normal_upper_bound), 3) + offset[2]), 2)

            # HUMIDITY
            if (flags[x][3] >= 1):
                humidity = round(base_hum * (round(random.uniform(anomaly_lower_bound, anomaly_upper_bound), 3) + offset[3]), 2)
            else:
                humidity = round(base_hum * (round(random.uniform(normal_lower_bound, normal_upper_bound), 3) + offset[3]), 2)

            data = {"timestamp": str(datetime.datetime.now()), "equipment_id": id, "vibration_amplitude": vibration_amplitude, "vibration_frequency": vibration_frequency, "temperature": tempurature, "humidity": humidity}
            payload_list.append(data)
            time.sleep(0.0003)

        payload = json.dumps(payload_list)
        encoded_value = b64encode(payload.encode()).decode()
        encoded_key = b64encode(str(id).encode()).decode()
        x = x+1

        # Send the message request to streaming service
        mesgs=[oci.streaming.models.PutMessagesDetailsEntry(value=encoded_value,key=encoded_key)]
        put_mesgs_dets=oci.streaming.models.PutMessagesDetails(messages=mesgs)
        put_messages_response = streaming_client.put_messages(stream_id=sid, put_messages_details=put_mesgs_dets)

        # Get the data from response
        if (put_messages_response.data.failures) == 0:
            message_count = message_count + len(payload_list)
            elapsed_time = (datetime.datetime.now() - start_time).seconds
            if elapsed_time > 0:
                rate = round(message_count / elapsed_time)
                print ('SENT: ' + str(message_count) + " - " + str(rate) + " msgs/sec")
            else:
                print ('SENT: ' + str(message_count))
        else:
            print ('MESSAGE FAILURE: ' + str(put_messages_response.data.failures))