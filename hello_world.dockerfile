# set the starting point
FROM ubuntu:latest

# install python and pandas
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    apt-get clean \
    rm -rf /var/lib/apt/lists

# we can git clone the code into the container
RUN cd /opt \
	export PATH=$PATH:/opt/hello_world

# an alternative would be to copy the code into the container
# COPY hello_world.py /opt/hello_world/hello_world.py
# RUN
