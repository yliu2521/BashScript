#!/bin/bash
#PBS -N all_in_one
##PBS -q yossarian
#PBS -l nodes=1:ppn=1
#PBS -l walltime=11:59:59
#PBS -l mem=1500MB
#PBS -V
#PBS -e PBSout/one_err_av
#PBS -o PBSout/one_out_av
##PBS -t 1-3

set -x
cd "$PBS_O_WORKDIR"
DATA_DIR="gamma_oscillation2"
MATLAB_SOURCE_PATH='SpikeNet'
MATLAB_SOURCE_PATH_2='myfunctions'
MATLAB_POST_PROCESS_FUNC="TimeFrequencyCImage"

# copy this script to data directory
me=`basename $0`;
THIS_FILE=$(echo ${me});
cp ${THIS_FILE} ${DATA_DIR}/${THIS_FILE}.log;
# copy the matlab main function to data directory
mfile=`find . -name "${MATLAB_POST_PROCESS_FUNC}.m"`;
MATLAB_FILE=$(echo ${mfile});
MATLAB_FILENAME=`basename ${mfile}`;
cp ${MATLAB_FILE} ${DATA_DIR}/${MATLAB_FILENAME}.log;


echo "%%%%%%%%%%%%%%%%%%%%%%%>>>>>>>>>>>>>>>>>>%%%%%%%%%%%%%%%%%%%%%%%%%%"
A=`date '+%s'`
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "ppmat: Current PBS_ARRAYID is ${PBS_ARRAYID}"
printf "\n"

ID=`printf "%04d" ${PBS_ARRAYID}`; # 3 digits, padded with leading  zeros
cd ${DATA_DIR};
OUTPUTFILE_ALL=$(echo ${ID}-*RYG.mat) # why here bash is different from c-shell?? 
# get the last (latest) ygout file
set -- $OUTPUTFILE_ALL
OUTPUTFILE=$(echo "${@: -1}")
echo "BASH OUTPUTFILE=${OUTPUTFILE}" # Note that echo actually does some processing!
cd ${PBS_O_WORKDIR}
# double quote here allows the real value of ${var} to be shown, otherwise echo will process it
# data post-process in matlab 
# double quote "" prevents shell from expanding meta-characters like "*" and "?"
# single quote '' prevents almost anything from happening to the text
# back quote `` means command substitution
matlab -nodisplay  -r "cd('${MATLAB_SOURCE_PATH}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
					   cd('${MATLAB_SOURCE_PATH_2}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
		               cd('${DATA_DIR}'), ${MATLAB_POST_PROCESS_FUNC}('${OUTPUTFILE}'), exit"
# the single quote here is for matlab to recognize string
# the double quote here is for shell to expand macros.



# zip files if mat done # It's NOT safe to use zip in PBS array job!!!!1
# cd ${DATA_DIR};
# matdone=`ls *mat | sed -n '/^'${ID}'-.*mat$/p'| wc -l`;
# if [ "${matdone}" == "1" ]; then
#	echo zipping ygfiles with loop number ${ID}...;
#	zip -T -q -m ${PBS_O_WORKDIR}/${DATA_DIR}/ygfiles ${ID}-*.ygin ${ID}-*.ygin_syn ${ID}-*.ygout;
#	echo zipping done.
#fi
# cd ${PBS_O_WORKDIR};


printf "\n"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
B=`date '+%s'`
C=`expr $B - $A`
printf 'Total elapsed time is %s sec.\n' $C
date
echo "%%%%%%%%%%%%%%%%%%%%%%%<<<<<<<<<<<<<<<<<<%%%%%%%%%%%%%%%%%%%%%%%%%%"
printf "\n\n\n"
set +x

 
