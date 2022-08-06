#!/bin/sh
find ./newsource/ -name \*.s -exec ./format_source.py {} \;
find ./newsource/ -name \*.i -exec ./format_source.py {} \;
