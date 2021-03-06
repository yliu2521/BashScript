#!/bin/bash
#PBS -N all_in_one
##PBS -q yossarian
#PBS -l nodes=1:ppn=1
#PBS -l walltime=111:59:59
#PBS -l mem=1500MB
#PBS -V
#PBS -e PBSout/one_err_av
#PBS -o PBSout/one_out_av
##PBS -t 1-3

set -x
cd "$PBS_O_WORKDIR"
DATA_DIR="tmp_data"
MATLAB_SOURCE_PATH='SpikeNet'
MATLAB_SOURCE_PATH_2='SpikeNet'
MATLAB_POST_PROCESS_FUNC="PostProcessYG"
CPP_MAIN_FUNC="simulator"

echo "%%%%%%%%%%%%%%%%%%%%%%%>>>>>>>>>>>>>>>>>>%%%%%%%%%%%%%%%%%%%%%%%%%%"
A=`date '+%s'`
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "All_in_one: Current PBS_ARRAYID is ${PBS_ARRAYID}"
printf "\n"


FIRST_LOOP=`printf "%04d" 1`; # so loop must start from 1
ID=`printf "%04d" ${PBS_ARRAYID}`; # 4 digits, padded with leading  zeros
if [ "${ID}" -eq "${FIRST_LOOP}" ]; then
	# copy this script to data directory
	me=`basename $0`;
	THIS_FILE=$(echo ${me});
	cp ${THIS_FILE} ${DATA_DIR}/${A}-${THIS_FILE}.log;
	# copy the matlab main function to data directory
	mfile=`find . -name "${MATLAB_POST_PROCESS_FUNC}.m"`;
	MATLAB_FILE=$(echo ${mfile});
	MATLAB_FILENAME=`basename ${mfile}`;
	cp ${MATLAB_FILE} ${DATA_DIR}/${A}-${MATLAB_FILENAME}.log;
fi




cd ${DATA_DIR};
${PBS_O_WORKDIR}/${CPP_MAIN_FUNC} ${ID}-*.ygin; # Simulate and output .ygout file
OUTPUTFILE_ALL=$(echo ${ID}-*.ygout) # why here bash is different from c-shell?? 
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
matlab -nodisplay -singleCompThread -r "cd('${MATLAB_SOURCE_PATH}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
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

 
