#!/usr/bin/env python
import os
import sys
import time
import requests
import json

#
# Batch request example in Python.
#

# get api_key from dashboard.mathpix.com or contact support@mathpix.com if you're in China
server = os.environ.get('MATHPIX_API', 'https://api.mathpix.com')
app = os.environ['MATHPIX_APP_ID']
key = os.environ['MATHPIX_APP_KEY']
headers={'app_id': app, 'app_key': key, 'Content-type': 'application/json'}

#
# Flag indicating whether you are running in a terminal and want to display
# partial progress.
#
interactive = True

urlbase = "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/"
images = [
    'algebra.jpg', 'fraction.jpg', 'graph.jpg', 'integral.jpg',
    'limit.jpg', 'long_division.jpg', 'matrix_2x2.jpg', 'matrix_3x3.jpg',
    'mixed_text_math.jpg', 'multiple_equations.jpg'
]
n = len(images)

urls = {}
for i, img in enumerate(images):
    urls['url-' + str(i + 1).zfill(2)] = urlbase + img

body = {'urls': urls, 'formats': ['latex_normal']}
start = time.time()
r = requests.post(server + '/v3/batch', headers=headers, data=json.dumps(body))
info = json.loads(r.text)
print info
b = info['batch_id']
print("Batch id is %s" % b)

#
# Polling frequency is based on a guess of how long the batch will take.
# One second per batch item is quite conservative but actual time depends
# on non-batch request traffic because batch requests are lower priority.
#
# We use a maximum wait time for interactive output. Server-side applications
# without screen output should just use an estimate.
#
progress = 0
estimate = n
if interactive:
    maxwait = 2.0

while True:
    timeout = float(estimate)
    if interactive:
        pct = float(100 * progress) / n
        sys.stdout.write('\r{0:5.1f}% {1}/{2}\033[K'.format(pct, progress, n))
        sys.stdout.flush()
        timeout = min(timeout, maxwait)

    time.sleep(timeout)

    r = requests.get(server + '/v3/batch/' + b, headers=headers)
    current = json.loads(r.text)
    results = current['results']
    progress = len(results)
    if progress == n:
        if interactive:
            print('\r{0:5.1f}% {1}/{2}'.format(100.0, progress, n))

        print('Batch results:')
        for key in sorted(results):
            result = results[key]
            answer = result.get('latex_normal', '') or result.get('error', '???')
            print(key + ': ' + answer)

        break

    # Adjust estimate based on how many items still need processing.
    if progress > 0:
        estimate = float(n - progress) * (time.time() - start) / float(progress)
