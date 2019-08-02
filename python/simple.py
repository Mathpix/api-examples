#!/usr/bin/env python3

import mathpix
import json

#
# Simple example of calling Mathpix OCR with ../images/algebra.jpg.
#
# We use the default ocr (math-only) and a single return format, latex_simplified.
#

r = mathpix.latex({
    'src': mathpix.image_uri('../images/algebra.jpg'),
    'formats': ['latex_simplified']
})

print(json.dumps(r, indent=4, sort_keys=True))
assert(r['latex_simplified'] == '12 + 5 x - 8 = 12 x - 10')
