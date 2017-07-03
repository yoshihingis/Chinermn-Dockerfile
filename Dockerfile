FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04

ENV http_proxy http://g3.konicaminolta.jp:8080
ENV https_proxy https://g3.konicaminolta.jp:8080

RUN apt-get update && apt-get install -y --no-install-recommends nano \
        openssh-server \
        git \
        python-dev \
        wget \
        make \
        wget \
        file \
        python-opencv \
        python-pip &&\
        rm -rf /var/lib/apt/lists/*

WORKDIR /home/

RUN wget http://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.gz

RUN tar xzvf openmpi-2.1.1.tar.gz

WORKDIR  openmpi-2.1.1

RUN ./configure --with-cuda
RUN make -j4
RUN make install
RUN ldconfig

#RUN which mpicc
#RUN mpicc -show
#RUN which mpiexec
#RUN mpiexec --version

WORKDIR /home/

RUN git clone https://github.com/NVIDIA/nccl.git

WORKDIR /home/nccl/

RUN make CUDA_HOME=/usr/local/cuda test

RUN make install

ENV PATH /usr/local/bin:/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV LIBRARY_PATH /usr/local/lib:$LIBRARY_PATH
ENV CPATH /usr/local/cuda/include:/usr/local/include:$CPATH

WORKDIR /home/data

RUN wget http://www.vision.caltech.edu/Image_Datasets/Caltech101/101_ObjectCategories.tar.gz

RUN tar xzvf 101_ObjectCategories.tar.gz

RUN git clone https://github.com/shi3z/chainer_imagenet_tools.git

WORKDIR chainer_imagenet_tools

RUN cp crop.py ../
RUN cp make_train_data.py ../

WORKDIR /home/

#RUN pip install numpy
#RUN pip install chainer
RUN pip install virtualenv
RUN virtualenv -p python3.4 py34
WORKDIR py34

RUN   . bin/activate && \ 
      apt-get update && apt-get install -y --no-install-recommends python3-dev &&\
      pip install cython && \
      pip install cupy && \
      pip install chainermn && \ 
      pip install pillow

RUN   git clone https://github.com/chainer/chainermn.git

WORKDIR /home/py34/

WORKDIR /home/py34/chainermn/examples

RUN cp -r imagenet /home/py34/lib/python3.4/site-packages/chainermn
RUN cp -r mnist /home/py34/lib/python3.4/site-packages/chainermn

WORKDIR /home/data

RUN cp -r 101_ObjectCategories /home/py34/lib/python3.4/site-packages/chainermn/imagenet
RUN cp crop.py  /home/py34/lib/python3.4/site-packages/chainermn/imagenet
RUN cp make_train_data.py  /home/py34/lib/python3.4/site-packages/chainermn/imagenet


WORKDIR /home/py34/lib/python3.4/site-packages/chainermn/imagenet/


RUN  python make_train_data.py 101_ObjectCategories

RUN mkdir images_raw

WORKDIR images

RUN mv *.* ../images_raw


WORKDIR /home/py34/lib/python3.4/site-packages/chainermn/imagenet/

RUN python crop.py ./images_raw ./images

WORKDIR /home/py34

RUN   . bin/activate && \
      cd /home/py34/lib/python3.4/site-packages/chainermn/imagenet && \
      python compute_mean.py train.txt


RUN  cd  /home/py34/



