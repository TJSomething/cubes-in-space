#!/usr/bin/bash

./build.sh && docker run -p 8080:8080 -it $(docker build -q .)