#!/usr/bin/env python
import os
import time
import requests
import json

#
# Batch request example in Python.
#

server = os.environ.get('MATHPIX_API', 'https://api.mathpix.com')
app = os.environ['MATHPIX_APP_ID']
key = os.environ['MATHPIX_APP_KEY']
headers={'app_id': app, 'app_key': key, 'Content-type': 'application/json'}

urlbase = "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/"
images = [ "algebra.jpg", "fraction.jpg", "integral.jpg" ]
n = len(images)

urls = {}
for i, img in enumerate(images):
    urls['url-' + str(i + 1)] = urlbase + img

body = {'urls': urls}
r = requests.post(server + '/v3/batch', headers=headers, data=json.dumps(body))
info = json.loads(r.text)
b = info['batch_id']
print("Batch id is %s" % b)

#
# Polling frequency is based on a guess of how long the batch will take.
# Half a second per batch item is conservative but actual time depends
# on non-batch request traffic because batch requests are lower priority.
#
estimate = 0.5 * n
while True:
    print("Waiting %.2g sec" % estimate)
    time.sleep(estimate)

    r = requests.get(server + '/v3/batch/' + b, headers=headers)
    current = json.loads(r.text)
    results = current['results']
    if results and len(results) == n:
        print('Batch complete')
        print(json.dumps(results, indent=4, sort_keys=True))
        break

    # Adjust estimate based on how many items still need processing.
    estimate = 0.5 * (n - len(results))
