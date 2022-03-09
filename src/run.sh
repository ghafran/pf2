#!/bin/bash

nvidia-smi
nvidia-smi --list-gpus | wc -l
/src/env.sh
python3 run.py
/src/copy.sh