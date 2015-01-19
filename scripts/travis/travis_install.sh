#!/bin/bash
set -e

MAKE="make --jobs=$NUM_THREADS"

apt-get -y update
apt-get install \
    wget git curl unzip ctags


CUDA_URL=http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1204/x86_64/cuda-repo-ubuntu1204_6.5-14_amd64.deb
CUDA_FILE=/tmp/cuda_install.deb
curl $CUDA_URL -o $CUDA_FILE
dpkg -i $CUDA_FILE
rm -f $CUDA_FILE

apt-get -y update
apt-get -y install cuda-core-6-5 cuda-cublas-6-5 cuda-cublas-dev-6-5 cuda-cudart-6-5 cuda-cudart-dev-6-5 cuda-curand-6-5 cuda-curand-dev-6-5 cuda

ln -s /usr/local/cuda-6.5 /usr/local/cuda
