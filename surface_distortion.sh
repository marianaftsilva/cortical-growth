#!/bin/bash -l
#SBATCH --job-name=aMSM_opt
#SBATCH --output=outputs/output.array.%A.%a
#SBATCH --array=0-90
#SBATCH --mem-per-cpu=8000
#SBATCH --time=1:00:00

module load openblas

SUBS_LIST=($(</users/k19068865/sub_IDs_preterms.txt))

SUB=${SUBS_LIST[${SLURM_ARRAY_TASK_ID}]} 

#SUB=$(echo ${subj} | cut -d "/" -f 1)
#SES_1=$(echo ${subj} | cut -d "/" -f 2)
#SES_2=$(echo ${subj} | cut -d "/" -f 3)

#cat sub_IDs_fetal.txt | while read line

#do

#subj=$line

#SUB=$(echo ${subj} | cut -d "/" -f 1)
#SES_1=$(echo ${subj} | cut -d "/" -f 2)
#SES_2=$(echo ${subj} | cut -d "/" -f 3)

DIR=/scratch/users/k19068865/longitudinal_dHCP
DIR=/scratch/users/k19068865/fetal-neonatal

#ANATOMICAL SURFACES
FAS="$DIR"/ico6/sub-${SUB}_ses-${SES_1}_left_midthickness_ico6.surf.gii 
NAS="$DIR"/ico6/sub-${SUB}_ses-${SES_2}_left_midthickness_ico6.surf.gii 

#NORMALIZED ANATOMICAL SURFACES
FNS="$DIR"/ico6/sub-${SUB}_ses-${SES_1}_left_midthickness_ico6_RESCALE.surf.gii 
NNS="$DIR"/ico6/sub-${SUB}_ses-${SES_2}_left_midthickness_ico6_RESCALE.surf.gii 

#SPHERICAL ORIGINAL SURFACES
FSS=ico-6.surf.gii
NSS=ico-6.surf.gii

NSSO="$DIR"/neonatal/sub-${SUB}/ses-${SES_NEO}/anat/Native/sub-${SUB}_ses-${SES_2}_left_sphere.surf.gii

MAXCP=ico-4.surf.gii #icosphere corresponding to final level CP resolution
MAXANAT=ico-6.surf.gii #icosphere corresponding to final level anat resolution

templatespherepath=dHCP_template_alignment/dhcpSym_template

template=$templatespherepath/week-40_hemi-right_space-dhcpSym_dens-32k_sphere.surf.gii 
templatemidthickness=$templatespherepath/week-40_hemi-right_space-dhcpSym_dens-32k_midthickness.surf.gii

# create un-normalized registration results by applying registration spheres to original surfaces
# first FAS registered to neonatal
wb_command -surface-resample $NAS $NSS results_aMSM/${SUB}_forward_left_sphere.reg.surf.gii BARYCENTRIC results_aMSM/${SUB}_FAS_left.reg.surf.gii

# then NAS registered to fetal
wb_command -surface-resample $FAS $FSS results_aMSM/${SUB}_reverse_left_sphere.reg.surf.gii BARYCENTRIC results_aMSM/${SUB}_NAS_left.reg.surf.gii

# calculate distortion between fetal original and registered - in fetal space 
wb_command -surface-distortion $FAS results_aMSM/${SUB}_forward_left_anat.reg.surf.gii results_aMSM/${SUB}_forward_left.surfdist.func.gii -local-affine-method 

# calculate distortion between neonatal original and registered - in neonatal space
wb_command -surface-distortion results_aMSM/${SUB}_NAS_left.reg.surf.gii $NAS results_aMSM/${SUB}_reverse_left.surfdist.func.gii -local-affine-method 

# resample forward distortion to session 2 space
wb_command -metric-resample results_aMSM/${SUB}_forward_left.surfdist.func.gii results_aMSM/${SUB}_forward_left.sphere.reg.surf.gii $NSS BARYCENTRIC results_aMSM/${SUB}_revfor_left.surfdist.func.gii 

# caculate average of distortion maps (cortical surface growth maps)
wb_command -metric-math '(J1+J2)/2' results_aMSM/${SUB}_avg_left.surfdist.func.gii -var J1 results_aMSM/${SUB}_reverse_left.surfdist.func.gii -column 1 -var J2 results_aMSM/${SUB}_revfor_left.surfdist.func.gii -column 1

wb_command -metric-math 'log2(x)' results_aMSM/${SUB}_avg_left_log.surfdist.func.gii -var x results_aMSM/${SUB}_avg_left.surfdist.func.gii

