#!/bin/bash

# ensure gpu available
nvidia-smi

# setup library links
/src/env.sh

# run fold
python3 run.py

# copy output to host
/src/copy.sh
