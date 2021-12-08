# TAG llalon/fish-risk-tree
FROM debian:bullseye-slim

WORKDIR /workflow
RUN mkdir -p bin/
COPY ./src/pipeline/* bin/
COPY ./src/tools/* bin/
ENV PATH "$PATH:/workflow/bin" 

RUN apt-get update && apt-get install -y wget \
    perl libsys-cpu-perl libjson-perl libjson-xs-perl liblwp-online-perl \
    muscle raxml

