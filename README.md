
# Run on g4dn.xlarge instance (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type), 120GB

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

## install docker and nvidia docker toolkit on host
```
curl https://get.docker.com | sh && sudo systemctl --now enable docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

## build docker image
This must run on a host with nvidia gpu and drivers
```
cd ~
git clone https://github.com/ghafran/pf2
cd ~/pf2
sudo docker build -t pf2 .
```
At this, point we should push the built image to an image respository

## run fold prediction
This must run on a host with nvidia gpu and drivers
```
cd ~/pf2
sudo docker run -it --rm --gpus all --name pf2test \
     -v "$(pwd)/output:/output" \
    -e "NAME=tsp1" \
    -e "SEQUENCE=MAAPTPADKSMMAAVPEWTITNLKRVCNAGNTSCTWTFGVDTHLATATSCTYVVKANANASQASGGPVTCGPYTITSSWSGQFGPNNGFTTFAVTDFSKKLIVWPAYTDVQVQAGKVVSPNQSYAPANLPLEHHHHHH" \
    pf2 /bin/sh -c "/src/run.sh"
```

# Download
```
scp -r -i ~/.ssh/at.pem 'ubuntu@35.173.1.112:/home/ubuntu/pf2/output/*' './output/'
```