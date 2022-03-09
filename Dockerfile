# FROM ubuntu:20.04
FROM nvidia/cuda:11.6.0-base-ubuntu20.04

# copy source code
COPY src /src
WORKDIR /src

# install packages
RUN apt-get update
RUN apt-get install -y python3 pip wget git unzip nano
RUN apt-get install -y libcublas-11-6 libcusparse-dev-11-6 libcurand-11-6

# extra functionality
RUN wget https://raw.githubusercontent.com/sokrypton/ColabFold/main/beta/colabfold.py

# download model
RUN git clone https://github.com/RosettaCommons/RoseTTAFold.git
RUN wget https://raw.githubusercontent.com/sokrypton/ColabFold/main/beta/RoseTTAFold__network__Refine_module.patch
RUN patch -u RoseTTAFold/network/Refine_module.py -i RoseTTAFold__network__Refine_module.patch

# download model params
RUN wget https://files.ipd.uw.edu/pub/RoseTTAFold/weights.tar.gz
RUN tar -xf weights.tar.gz
RUN rm weights.tar.gz

# download scwrl4 (for adding sidechains)
# http://dunbrack.fccc.edu/SCWRL3.php
RUN wget https://files.ipd.uw.edu/krypton/TrRosetta/scwrl4.zip
RUN unzip -qqo scwrl4.zip

# install libraries
RUN pip install pip_search
RUN pip install dgl-cu113 -f https://data.dgl.ai/wheels/repo.html
RUN pip install torch==1.10.0+cu111 -f https://download.pytorch.org/whl/cu111/torch_stable.html
RUN pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.10.0+cu113.html
RUN pip install torch-sparse -f https://pytorch-geometric.com/whl/torch-1.10.0+cu113.html
# RUN pip install torchvision -f https://pytorch-geometric.com/whl/torch-1.10.0+cu113.html
RUN pip install torch-geometric
RUN pip install ipython
RUN pip install jax
RUN pip install jaxlib
RUN pip install py3Dmol
RUN pip install matplotlib-venn
RUN pip install pydot

RUN chmod +x env.sh

