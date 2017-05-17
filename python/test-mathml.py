#!/usr/bin/env python
import sys
import base64
import requests
import json

file_path = sys.argv[1]
image_uri = "data:image/jpg;base64," + base64.b64encode(open(file_path, "rb").read())
r = requests.post("https://api.mathpix.com/v3/latex",
    data=json.dumps({'url': image_uri, 'formats': {'mathml': True}}),
    headers={"app_id": "trial", "app_key": "34f1a4cea0eaca8540c95908b4dc84ab",
        "Content-type": "application/json"})
print json.loads(r.text)['mathml']
