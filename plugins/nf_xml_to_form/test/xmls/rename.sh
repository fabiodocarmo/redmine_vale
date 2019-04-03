#!/bin/bash

for file in *.xml.output; do mv "$file" "${file%.xml.output}.xml"; done
