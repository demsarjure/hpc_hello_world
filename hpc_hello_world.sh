#!/bin/bash
#SBATCH --job-name=hpc_hello_world
#SBATCH --output=output.txt
#SBATCH --error=error.txt
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --mem-per-cpu=2gb

singularity exec -B ~:/host_folder hpc_hello_world.sif python3 /opt/hpc_hello_world/hello_world.py -i "/host_folder/data.csv" -o "/host_folder/test.txt"
