#!/bin/bash -l
#SBATCH --job-name=aMSM_r1
#SBATCH --output=outputs/output.array.%A.%a
#SBATCH --array=0-92
#SBATCH --mem-per-cpu=8000
#SBATCH --time=24:00:00

module load openblas
SUBS_LIST=($(</list_subs.txt))
FETAL_LIST=($(</list_fetal.txt))
NEO_LIST=($(</list_neo.txt))

SUB=${SUBS_LIST[${SLURM_ARRAY_TASK_ID}]} 
SES_FETAL=${FETAL_LIST[${SLURM_ARRAY_TASK_ID}]}
SES_NEO=${NEO_LIST[${SLURM_ARRAY_TASK_ID}]}

# top directory for data
DIR=/fetal-neonatal

# right hemisphere

# ANATOMICAL SURFACES
FNS="$DIR"/ico6/sub-${SUB}_ses-${SES_FETAL}_right_midthickness_ico6.surf.gii 
NNS="$DIR"/ico6/sub-${SUB}_ses-${SES_NEO}_right_midthickness_ico6.surf.gii 

SS=ico-6.surf.gii #icosphere is spherical surface

# CURVATURE
FC="$DIR"/ico6/sub-${SUB}_ses-${SES_FETAL}_right_curvature_ico6.shape.gii
NC="$DIR"/ico6/sub-${SUB}_ses-${SES_NEO}_right_curvature_ico6.shape.gii

# forward registration: scan 1 to scan 2
msm --indata=$FC --inanat=$FNS --inmesh=$SS --refdata=$NC --refanat=$NNS --refmesh=$SS --conf=aMSM_configs/config_amsm_fetal_neonatal -o results_aMSM/${SUB}_forward_right_

# reverse registration: scan 2 to scan 1
msm --indata=$NC --inanat=$NNS --inmesh=$SS --refdata=$FC --refanat=$FNS --refmesh=$SS --conf=aMSM_configs/config_amsm_fetal_neonatal -o results_aMSM/${SUB}_reverse_right_

#do the same for left hemisphere

# ANATOMICAL SURFACES
FNS="$DIR"/ico6/sub-${SUB}_ses-${SES_FETAL}_left_midthickness_ico6.surf.gii 
NNS="$DIR"/ico6/sub-${SUB}_ses-${SES_NEO}_left_midthickness_ico6.surf.gii 

SS=ico-6.surf.gii #icosphere is spherical surface

# CURVATURE
FC="$DIR"/ico6/sub-${SUB}_ses-${SES_FETAL}_left_curvature_ico6.shape.gii
NC="$DIR"/ico6/sub-${SUB}_ses-${SES_NEO}_left_curvature_ico6.shape.gii

# forward registration: scan 1 to scan 2
msm --indata=$FC --inanat=$FNS --inmesh=$SS --refdata=$NC --refanat=$NNS --refmesh=$SS --conf=aMSM_configs/config_amsm_fetal_neonatal -o results_aMSM/${SUB}_forward_left_

# reverse registration: scan 2 to scan 1
msm --indata=$NC --inanat=$NNS --inmesh=$SS --refdata=$FC --refanat=$FNS --refmesh=$SS --conf=aMSM_configs/config_amsm_fetal_neonatal -o results_aMSM/${SUB}_reverse_left_

