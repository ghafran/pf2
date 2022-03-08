# fix library
export LD_CUDA_PATH=/usr/local/cuda-11.6/targets/x86_64-linux/lib:/usr/local/lib/python3.8/dist-packages/torch/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LD_CUDA_PATH}