#!/bin/bash

./CMakeClean.sh deep

./11.build-node.sh 2>&1 | tee node.log
if [ $? -ne 0 ]; then exit 1; fi


