#!/bin/python

import secrets
import pyperclip

r = hex(secrets.randbits(32))
print(r)
pyperclip.copy(r)


