
# Run on g4dn.xlarge instance

## install nvidia drivers on host
```
ssh -i ~/.ssh/at.pem ubuntu@35.173.1.112
sudo apt update
sudo apt upgrade -y
sudo apt install -y gcc
sudo apt install -y linux-headers-$(uname -r)
sudo apt install -y nvidia-driver-460
sudo reboot
nvidia-smi
nvidia-smi --list-gpus | wc -l
```

## install docker and nvidia docker tookkit
```
curl https://get.docker.com | sh && sudo systemctl --now enable docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## run fold prediction
```
git clone https://github.com/ghafran/pf2
cd pf2
sudo docker build -t pf2 .
sudo docker run -it --rm --gpus all --name pf2test \
     -v "$(pwd)/output:/output" \
    -e "NAME=tsp1" \
    -e "SEQUENCE=MAAPTPADKSMMAAVPEWTITNLKRVCNAGNTSCTWTFGVDTHLATATSCTYVVKANANASQASGGPVTCGPYTITSSWSGQFGPNNGFTTFAVTDFSKKLIVWPAYTDVQVQAGKVVSPNQSYAPANLPLEHHHHHH" \
    pf2 bash
```

# Download
```
scp -r -i ~/.ssh/at.pem 'ubuntu@35.173.1.112:/home/ubuntu/pf2/output/*' './output/'
```



# test on local mac 
```
docker buildx build --platform linux/amd64 -t pf2 .
docker run -it --rm --platform linux/amd64 --name pf2test \
    -e "NAME=tsp1" \
    -e "SEQUENCE=MAAPTPADKSMMAAVPEWTITNLKRVCNAGNTSCTWTFGVDTHLATATSCTYVVKANANASQASGGPVTCGPYTITSSWSGQFGPNNGFTTFAVTDFSKKLIVWPAYTDVQVQAGKVVSPNQSYAPANLPLEHHHHHH" \
    pf2 bash
```