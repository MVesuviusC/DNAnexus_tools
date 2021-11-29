#!/bin/sh
#SBATCH --account=accountHere
#SBATCH --error=forceDownload_%j.txt
#SBATCH --output=forceDownload_%j.txt
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --job-name forceDownload
#SBATCH --wait
#SBATCH --array=0-999%30

set -e ### stops bash script if line ends with error

echo ${HOSTNAME} ${SLURM_ARRAY_TASK_ID}

linkArray=($(cut -d " " -f 1 downloadFile.txt))
md5Array=($(cut -d " " -f 2 downloadFile.txt))

currentLink=${linkArray[$SLURM_ARRAY_TASK_ID]}
currentMd5=${md5Array[$SLURM_ARRAY_TASK_ID]}

perl ~/scripts/dnaNexusDl.pl \
    --link ${currentLink} \
    --md5 ${currentMd5}
