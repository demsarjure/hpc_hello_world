# Introduction

The purpose of this document is to introduce students from the Faculty of Computer and Information Science (FRI) at the University of Ljubljana with the basics concepts and technologies used in high performance computing (HCP) systems. This knowledge should allow students to start using HPC systems in their own study projects.

## Example python script

In this tutorial we will try to containerize the following python script (`hpc_hello_world.py`):

``` python
#!/usr/bin/python

# imports
import getopt
import os
import sys
import pandas as pd

def main(argv):
  # set
  input_file = None
  output_file = None

  # read input and output files
  opts, _ = getopt.getopt(argv,"i:o:")
  for opt, arg in opts:
    if opt == "-i":
      input_file = arg
    elif opt == "-o":
      output_file = arg

  # error out
  if input_file is None or output_file is None:
    print("ERROR: Input (-i) or output (-o) not provided!")
    sys.exit(1)

  # load data
  if os.path.exists(input_file):
    df = pd.read_csv(input_file)
  else:
    print("ERROR: Input file [%s] does not exist!" % input_file)
    sys.exit(2)

  # sum
  sum = 0
  for _, row in df.iterrows():
    sum = sum + row[0] + row[1]

  # save the result in output file
  f = open(output_file, "a")
  f.write("Sum = %s\n" % sum)
  f.close()

if __name__ == "__main__":
  main(sys.argv[1:])
```

The scripts takes two arguments (`-i` and `-o`), the first argument (`-i`) specifies the input data file, in our case the input file is a `.csv` file that contains two columns of numbers:

``` csv
15,20
10,30
20,10
20,30
```

Our scripts reads each row and sums up all the numbers. It then prints the result into the file specified withe the `-o` argument. A valid run of the script would thus be:

``` bash
python3 hpc_hello_world.py -i data.csv -o test.txt
```

This call would read and summarize the numbers inside the `data.csv` file and print the result in `test.txt`.

## Getting access to a HPC system

The first thing we need is access to an HPC system. To get it you should write an email to the administrator at FRI. For the purpose of this tutorial we will assume that our username is `juredemsar` (or `demsarjure` in the case of the Git repository). The HPC system used in this example is called `Trdina`, which is one of the systems in the Slovenian national supercomputing network (SLING). The code works on any of the system though, the only thing you need to change is the address your are logging into. Once you get access credentials you can use console/terminal and `ssh` to log into the system:

``` bash
ssh juredemsar@trdina-login.fis.unm.si
```

By default you will have to provide a password every time you login. To increase the security and make life easier, we traditionally setup the ssh keypair access. To allow access to the server with your ssh key, you should copy your public part of the key into the `~/.ssh/authorized_keys` file (`~` denotes your home folder) on the HCP system. If you do not an ssh keypair you can easily generate one, see [https://www.ssh.com/ssh/keygen/](https://www.ssh.com/ssh/keygen/) for instructions.

## The login and the compute nodes

Once we login into a HCP system we land on a node. Here, it is important to distinguish between login and compute nodes. The node that we are on once we login is called the login node and is not intended for execution of any real processing (all processes that run too long get terminated, the node is very weak in terms of hardware, etc.). We use a login node only to schedule tasks, which are then ran on compute nodes. But before we get to scheduling, we need to take a look at containers.

## Docker containers

You might imagine that maintenance of a HCP system would be impossible if administrators would have to tune the systems to whims of all users (everyone needs their own libraries, dependencies, versions of tools, etc.). Containers offer a solution to this problem, through containers we can encapsulate/virtualize the whole processing ecosystem (an OS, all libraries and dependencies and our code) into a single image that is then used by the HCP system for processing.

In this tutorial we will use Docker ([https://www.docker.com/](https://www.docker.com/)) to prepare the container. Docker is the most widely spread containerization solution, besides the containerization Docker offers a hub which we can use to easily transfer our containers to HPC systems. Our HPC system actually uses Singularity and not Docker due to higher security. As you will see, building a Singularity image from a Docker image is trivial.

### The dockerfile

Docker images are built from dockerfiles. Below is an example of the dockerfile we will use in this tutorial:

``` bash
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
# COPY hpc_hello_world.py /opt/hpc_hello_world/hpc_hello_world.py
```

The `FROM` command sets the starting point, here I used a clean image of the latest version of Ubuntu OS. Traditionally, we will not use `ubuntu:latest` since the docker hub contains a number of pre-prepared images that better suit our needs. For example, the `python:latest` image has python and core files needed for working with python already installed, by using this image our dockerfile would be much shorter. Such images exist for most commonly used toolsets (e.g., TensorFlow, PyTorch, etc.).

The second command we are using is called `RUN`, this command simply runs a bash command inside the installed Ubuntu OS. We use it to install python and other required tools and dependencies. As you can see you can chain multiple commands together by using `&& \` (`&&` is for chaining commands while `\` is for a line break so our dockerfile is reader friendly). The last portion of our dockerfile again uses the `RUN` command, this time we use it to clone our Git repository into the Docker container. We could just as well chain these last block together with the first `RUN` block. An alternative to using Git and getting our code into the container would be to use a `COPY` command and copy local files into the container.

### Building the container image

Once our dockerfile is ready and Docker is up and running on our system we can build our Docker container image:

``` bash
docker build -f hpc_hello_world.dockerfile -t juredemsar/hpc_hello_world:1.0.0 .
```

With `-f` we specify which dockerfile to use and with `-t` we label and tag/version our container. The `juredemsar/hpc_hello_world` portion of the name comes from the way we named our Docker repository. On the Docker hub webpage ([https://hub.docker.com/](https://hub.docker.com/)) we have opened a new repository called `hpc_hello_world` under my username (`juredemsar`). The last argument `.` tells the command to work in the current folder. For additional options when building a Docker container consult [https://docs.docker.com/engine/reference/commandline/build/](https://docs.docker.com/engine/reference/commandline/build/).

### Running the container

Once our container is built we have our whole environment (OS, libraries, dependencies, tools, etc.) packed in a single container image. This means that we can run our code in the exact same environment on every system that has Docker installed. This comes in handy, because we can easily transfer our work to new system or allow other researchers or developers to exactly reproduce our work without much hassle. We can try if it works by using the `docker run` command:

``` bash
docker run -v "D:/Projects/hpc_hello_world:/host_folder" juredemsar/hpc_hello_world:1.0.0 python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
```

Again, there are a couple of things to unpack here. We start with the `docker run` command. The command is follower by the `-v` parameter, which we use to bind folders from the host computer (in this case my computer) into the container. In my case I am mapping `D:/Projects/hpc_hello_world` from my Windows desktop into `/host_folder` inside the Ubuntu container. This way container can access everything I have inside `D:/Projects/hpc_hello_world` through its internal `/host_folder`. This can also be seen in the command where I am specifying input and output files. I have files inside `D:/Projects/hpc_hello_world` on my local computer, but inside the container they will be accessed through `/host_folder`.

The next part of the `docker run` command is the image we will use, in our case this is `juredemsar/hpc_hello_world:1.0.0` that we just built. The final part is the command that we will run inside the container in our case this is the prepared python script:

``` bash
python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
```

You can see that input and output files need to be defined from containers perspective. Container does not have direct access to `D:/Projects/hpc_hello_world`, it can access it through our binding tha we made with the `-v` parameter. For additional options regarding `docker run` see [https://docs.docker.com/engine/reference/commandline/run/](https://docs.docker.com/engine/reference/commandline/run/).

We can also enter the container interactively, this is useful so we can check if everything we want is inside the container:

``` bash
docker run -it juredemsar/hpc_hello_world:1.0.0 bash
```

## Transferring the container and data to the HPC system

We will first transfer the container to the Docker hub, we will later use this hub to build a container image on the HPC. This is very simple, we just have to login to Docker (if we are not already logged in) and push the built image to the Docker hub:

``` bash
# if we want to push to our docker repository we need to be logged in
docker login

# push the previously built image
docker push juredemsar/hpc_hello_world:1.0.0
```

To transfer files from our local system to HCP we will use `scp`:

``` bash
scp D:/Projects/hpc_hello_world/data.csv jdemsar@trdina-login.fis.unm.si:~
```

This command has the following format `scp <source> <destination>`. In our case we are copying a local file `D:/Projects/hpc_hello_world/data.csv` to my (`jdemsar`) home folder (`~`) on Trdina HPC (`trdina-login.fis.unm.si`). To copy the whole folder we need to use the recursive flag (`-r`), the command below would copy the whole `D:/Projects/hpc_hello_world` folder into my home folder on Trdina:

``` bash
scp -r D:/Projects/hpc_hello_world jdemsar@trdina-login.fis.unm.si:~/hpc_hello_world
```

## Singularity

Since Docker poses some security risks on multi user systems a lot of publicly accessible HPCs use Singularity ([https://singularity.lbl.gov/](https://singularity.lbl.gov/)) instead. For us this does not change much, we just have to use Singularity to build the image on the HPC:

``` bash
singularity build hpc_hello_world.sif docker://juredemsar/hpc_hello_world:1.0.0
```

Singularity stores images in files (Docker stores them in its own system running in the background), so with `hpc_hello_world.sif` we specify in which file we will store this image. With `docker://juredemsar/hpc_hello_world:1.0.0` we specify which Docker image we want to use for building.

Docker allows you to have one free private repository, if you are using a private repository then you need to provide Singularity with your username and run build with the `--docker-login` option, later you will be also prompted to provide your password:

``` bash
export SINGULARITY_DOCKER_USERNAME=<Docker username>
singularity build --docker-login hpc_hello_world.sif docker://juredemsar/hpc_hello_world:1.0.0
```

The result of this command will be a file called `hpc_hello_world.sif`, which will store our whole processing environment. Once the Singularity image file is ready we can use it to run our script, with Singularity this is done similarly as with Docker:

``` bash
singularity exec -B ~:/host_folder hpc_hello_world.sif python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
```

We use `singularity exec` to execute a particular command inside the container, here `-B` or `--bind` is used for binding host folders into container (similar to `-v` with Docker). Again, we can enter the container interactively to inspect it:

``` bash
singularity shell hpc_hello_world.sif
```

## Scheduling

So far we were running things on our login node. Like mentioned above, login nodes have weak hardware and will terminate your processes if they will run too long. To run our tasks on compute nodes we need to schedule them via Simple Linux Utility for Resource Management (SLURM, [https://slurm.schedmd.com/](https://slurm.schedmd.com/)). With SLURM we traditionally create shell scripts with a special header that describes what kind of resources we need. The more resources we demand the longer we will have to wait to get them, so do not reserve resources that you do not need, because it will cost both your time and time of other users of the system. Below is an example of a shell script (`hpc_hello_world.sh`):

``` bash
#!/bin/bash
#SBATCH --job-name=hpc_hello_world
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=10:00

singularity exec -B ~:/host_folder hpc_hello_world.sif python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
```

You can see that SLURM parameters are specified with `#SBATCH`, with `--job-name`we determines the name of the job (this will be seen later when we will be tracking the job), next we define where SLURM will put outputs (printouts) and errors (if they occur). With the last three rows we determine that we will be running a single task (single process) on a single CPU for at most 10 minutes and we need 2gb of RAM for it. For a list of other possible SLURM options see [https://slurm.schedmd.com/sbatch.html](https://slurm.schedmd.com/sbatch.html). After the SLURM header we specify the commands we want to run, in our case this will be the `singularity exec` command we ran before. Before we ran it on the login not, but now it will be ran on a much more powerful compute node! To schedule our job we execute:

``` bash
sbatch hpc_hello_world.sh
```

We can check what is going on with our command by executing:

``` bash
squeue -u jdemsar
```

Under the `ST` column we can see the status, there `PD` means that the job is waiting for resources, `R` means that it is running and `C` means that is has completed. If the job is not visible on the list it already finished (command gets cleaned up in a couple of seconds after finishing). You can run just `squeue` to see all jobs that are currently in the system. These HPCs usually also have a bunch of powerful GPUs to use those you need to tell this to SLURM and Singularity. For example, if our simple script would require GPUs, we would need to amend the shell script:

``` bash
#!/bin/bash
#SBATCH --job-name=hpc_hello_world
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2gb
#SBATCH --time=10:00
#SBATCH --partition=gpu
#SBATCH --gpus=1

singularity exec --nv -B ~:/host_folder hpc_hello_world.sif python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
```

There are a couple of simple changes here, we used `--partition` to tell SLURM that our job needs to be assigned to the partition of the whole system that has GPUs, with `--gpus=1` we reserve one GPU. You can also see that we added `--nv` to the `singularity exec` call, this is required for NVIDIA CUDA, since it tells Singularity that it has to link system's CUDA resources with the container.

## The end

Congratulation, you made it to the end of the tutorial. Happy HPC-ing!
