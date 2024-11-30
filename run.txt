#!/bin/bash

# Exit if any command fails
set -e

# SLURM Job Submission Directives
#SBATCH --job-name=AHDS          # Name of the job
#SBATCH --partition=teach_cpu            # Partition name
#SBATCH --nodes=1                        # Number of nodes
#SBATCH --ntasks=1                       # Number of tasks (typically the same as nodes for simple jobs)
#SBATCH --cpus-per-task=1                # Number of cores per task
#SBATCH --mem=12G                        # Memory per node
#SBATCH --time=6:00:00                  # Time limit hrs:min:sec
#SBATCH --output=AHDS_%j.log     # Standard output and error log
#SBATCH --account=SSCM033324

conda activate work_env

snakemake

