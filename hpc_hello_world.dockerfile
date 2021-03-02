# set the starting point
FROM ubuntu:latest

# install git, python and pandas
RUN apt-get update && \
    apt-get install -y python3.9 python3-pip git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    pip3 install pandas

# we can git clone the code into the container
RUN cd /opt && \
    git clone https://github.com/demsarjure/hpc_hello_world.git

# an alternative would be to copy local code into the container
# COPY hello_world.py /opt/hello_world/hello_world.py
