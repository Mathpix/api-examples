#!/usr/bin/env python3

import mathpix
import json

#
# Example using Mathpix OCR with multiple result formats. We want to recognize
# both math and text in the image, so we pass the ocr parameter set to
# ['math', 'text']. This example returns both the text format, which
# starts in text mode instead of math mode, and the latex_styled format.
# We also define custom math delimiters for the text result so that
# the math is surrounded by dollar signs ("$").
#

r = mathpix.latex({
    'src': mathpix.image_uri('../images/mixed_text_math.jpg'),
    'ocr': ['math', 'text'],
    'skip_recrop': True,
    'formats': ['text', 'latex_styled'],
    'format_options': {
        'text': {
            'transforms': ['rm_spaces', 'rm_newlines'],
            'math_delims': ['$', '$']
        },
        'latex_styled': {'transforms': ['rm_spaces']},
    }
})

print(json.dumps(r, indent=4, sort_keys=True))
assert(r['text'] == '$-10 x^{2}+5 x-3$ and $-7 x+4$')
assert(r['latex_styled'] == '-10 x^{2}+5 x-3 \\text { and }-7 x+4')
