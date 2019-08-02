#!/usr/bin/env python3

import mathpix
import json

#
# Example using Mathpix OCR with multiple result formats. We want to recognize
# both math and text in the image, so we pass the ocr parameter set to
# ['math', 'text']. This example returns the LaTeX text format, which
# starts in text mode instead of math mode, the latex_styled format,
# the asciimath format, and the mathml format. We define custom
# math delimiters for the text result so that the math is surrounded
# by dollar signs ("$").
#

r = mathpix.latex({
    'src': mathpix.image_uri('../images/mixed_text_math.jpg'),
    'ocr': ['math', 'text'],
    'skip_recrop': True,
    'formats': ['text', 'latex_styled', 'asciimath', 'mathml'],
    'format_options': {
        'text': {
            'transforms': ['rm_spaces', 'rm_newlines'],
            'math_delims': ['$', '$']
        },
        'latex_styled': {'transforms': ['rm_spaces']}
    }
})

#
# Note the actual results might be slighly different in LaTeX spacing or
# MathML attributes.
#

print('Expected for r["text"]: "$-10 x^{2}+5 x-3$ and $-7 x+4$"')
print('Expected for r["latex_styled"]: "-10 x^{2}+5 x-3 \\text { and }-7 x+4"')
print('Expected for r["asciimath"]: "-10x^(2)+5x-3\\" and \\"-7x+4"')
print('Expected for r["mathml"]: "<math><mo>\u2212</mo><mn>10</mn><msup><mi>x</mi><mn>2</mn></msup><mo>+</mo><mn>5</mn><mi>x</mi><mo>\u2212</mo><mn>3</mn><mtext>\u00a0and\u00a0</mtext><mo>\u2212</mo><mn>7</mn><mi>x</mi><mo>+</mo><mn>4</mn></math>"')

print("\nResult object:", json.dumps(r, indent=4, sort_keys=True))
