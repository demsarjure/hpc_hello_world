# Introduction

The purpose of this document is to introduce students from the Faculty of Computer and Information Science (FRI) at the University of Ljubljana with the basics concepts and technolgoies used in high performance computing (HCP) systems. This knowledge should allow students to start using HPC systems in their own study projects.

## Getting access

The first thing we need is access to an HPC system. To get it you should write an email to the administrator at FRI. For the purpose of this tutorial we will assume that our username is `jnovak`. The HPC system used in this example is called `Trdina`, which is one of the systems in the Slovenian national supercomputing network (SLING). The code works on any of the system though, the only thing you need to change is the address your are logging into. Once you get access credentials you can use console/terminal and `ssh` to log into the system:

``` bash
ssh jnovak@trdina-login.fis.unm.si
```

By default you will have to provide a password every time you login. To increase the security and make life easier, we traditionally setup the ssh keypair access. To allow access to the server with your ssh key, you should copy your public part of the key into the `~/.ssh/authorized_keys` file (`~` denotes your home folder) on the HCP system. If you do not an ssh keypair you can easily generate one, see [https://www.ssh.com/ssh/keygen/](https://www.ssh.com/ssh/keygen/) for instructions.

## The login and the compute nodes

Once we login into a HCP system we land on a node. Here, it is important to distinguish between login and compute nodes. The node that we are on once we login is called the login node and is not intended for execution of any real processing (all processes that run too long get terminated, the node is very weak in terms of hardware, etc.). We use a login node only to schedule tasks, which are then ran on compute nodes. But before we get to scheduling, we need to take a look at containers.

## Containers

You might imagine that maintenance of a HCP system would be impossible if administrators would have to tune the systems to whims of all users (everyone needs their own libraries, dependencies, versions of tools, etc.). Containers offer a solution to this problem, through containers we can encapsulate/virtualize the whole processing ecosystem (an OS, all libraries and dependencies and our code) into a single image that is then used by the HCP system for processing.

In this tutorial we will use Docker ([https://www.docker.com/](https://www.docker.com/)) to prepare the container. Docker is the most widely spread containerization solution, besides the containerization Docker offers a hub which we can use to easily transfer our containers to HPC systems. The HPC system we will use actually use Singularity and not Docker because of higher security. As you will see, building a Singularity image from a Docker image is trivial.




docker build -f hello_world.dockerfile -t juredemsar/hpc_hello_world:1.0.0 .

docker push juredemsar/hpc_hello_world:1.0.0

## Transfering data to the HPC system



## Scheduling

