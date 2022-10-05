FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

WORKDIR /workspace

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    vim \
    git \
    unzip \
    build-essential \
    libasound2-dev \
    libjack-dev \
    portaudio19-dev \
    libsndfile1-dev


RUN wget https://repo.continuum.io/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh -O Miniconda.sh && \
    bash Miniconda.sh -b -p /opt/miniconda3 && \
    rm Miniconda.sh
ENV PATH /opt/miniconda3/bin:$PATH

RUN git clone https://github.com/work82mj/magenta
COPY ./requirements.txt ./
RUN pip install -r requirements.txt
RUN cd magenta && pip install -e .