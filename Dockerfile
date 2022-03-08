# FROM ubuntu:20.04
FROM nvidia/cuda:11.6.0-base-ubuntu20.04

# copy source code
COPY src /src
WORKDIR /src

# install packages
RUN apt update
RUN apt install python3 pip wget git unzip nano -y

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
RUN pip install dgl-cu113 -f https://data.dgl.ai/wheels/repo.html
RUN pip install torch-scatter -f https://pytorch-geometric.com/whl/torch-1.10.0+cu113.html
RUN pip install torch-sparse -f https://pytorch-geometric.com/whl/torch-1.10.0+cu113.html
RUN pip install torch-geometric
RUN pip install torchvision
RUN pip install ipython
RUN pip install py3Dmol