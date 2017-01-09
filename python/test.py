#!/usr/bin/env python
import sys
import requests
import json

if len(sys.argv) < 2:
    print "Must supply file input!"
    exit()

file_path = sys.argv[1]
r = requests.post('http://api.mathpix.com/v2/latex',
    files={'file': open(file_path, 'rb')}, 
    headers={"app_id": "4985f625", "app_key": "4423301b832793e217d04bc44eb041d3"})
text = r.text
print json.dumps(json.loads(text), indent=4, sort_keys=True)
