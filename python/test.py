#!/usr/bin/env python
import sys
import requests
import json

if len(sys.argv) < 2:
    print "Must supply file input!"
    exit()

file_path = sys.argv[1]
r = requests.post('https://api.mathpix.com/v2/latex',
    files={'file': open(file_path, 'rb')},
    headers={"app_id": "YOUR APP ID", "app_key": "YOUR APP KEY"})
text = r.text
print json.dumps(json.loads(text), indent=4, sort_keys=True)
