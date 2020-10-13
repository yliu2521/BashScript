#!/bin/bash
#PBS -S /bin/bash
#PBS -N yliu2
##PBS -q yossarian
#PBS -l nodes=1:ppn=1
#PBS -l walltime=29:59:59
#PBS -l mem=1500MB
#PBS -V
#PBS -e PBSout/one_err_av
#PBS -o PBSout/one_out_av
##PBS -t 1-3

# module load HDF5-1.10.0 # add this (and other modules you may need) to your shell config!

set -x
cd "$PBS_O_WORKDIR"
DATA_DIR="SPModel/AreaLoad/0043-0049Repeat100Trials"
MATLAB_SOURCE_PATH='SpikeNet'
MATLAB_SOURCE_PATH_2='myfunctions'
MATLAB_SOURCE_PATH_3='OtherFunctions'
MATLAB_PRE_PROCESS_FUNC="PostProcess"
# MATLAB_POST_PROCESS_FUNC="PostProcessYL"
# CPP_MAIN_FUNC="simulator"


echo "%%%%%%%%%%%%%%%%%%%%%%%>>>>>>>>>>>>>>>>>>%%%%%%%%%%%%%%%%%%%%%%%%%%"
A=`date '+%s'`
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "Yliu: Current PBS_ARRAYID is ${PBS_ARRAYID}, but actually not needed"
printf "\n"

FIRST_LOOP=`printf "%04d" 1`; # so loop must start from 1
ID=`printf "%04d" ${PBS_ARRAYID}`; # 4 digits, padded with leading  zeros
if [ "${ID}" -eq "${FIRST_LOOP}" ]; then
	# copy this script to data directory
	me=`basename $0`;
	THIS_FILE=$(echo ${me});
	cp ${THIS_FILE} ${DATA_DIR}/${A}-${THIS_FILE}.log;
	# copy the matlab main function to data directory
	mfile=`find . -name "${MATLAB_PRE_PROCESS_FUNC}.m"`;
	MATLAB_FILE=$(echo ${mfile});
	MATLAB_FILENAME=`basename ${mfile}`;
	cp ${MATLAB_FILE} ${DATA_DIR}/${A}-${MATLAB_FILENAME}.log;
	mfile=`find . -name "${MATLAB_POST_PROCESS_FUNC}.m"`;
	MATLAB_FILE=$(echo ${mfile});
	MATLAB_FILENAME=`basename ${mfile}`;
	cp ${MATLAB_FILE} ${DATA_DIR}/${A}-${MATLAB_FILENAME}.log;
fi

cd ${PBS_O_WORKDIR};

	matlab -singleCompThread -nodisplay  -r "cd('${MATLAB_SOURCE_PATH}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}') , \
						   cd('${MATLAB_SOURCE_PATH_2}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
                                                   cd('${MATLAB_SOURCE_PATH_3}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
						   cd('${DATA_DIR}'), ${MATLAB_PRE_PROCESS_FUNC}, exit" # Create ${INPUT_APPENDIX} file
	# cd ${DATA_DIR};
	# ${PBS_O_WORKDIR}/${CPP_MAIN_FUNC} ${ID}-*${INPUT_APPENDIX}; # Simulate and output ${OUTPUT_APPENDIX} file
	# OUTPUTFILE=$(echo ${ID}-*${OUTPUT_APPENDIX}) # why here bash is different from c-shell?? 
	# echo "BASH OUTPUTFILE=${OUTPUTFILE}" # Note that echo actually does some processing!
	# cd ${PBS_O_WORKDIR};
	# double quote here allows the real value of ${var} to be shown, otherwise echo will process it
	# data post-process in matlab 
	# double quote "" prevents shell from expanding meta-characters like "*" and "?"
	# single quote '' prevents almost anything from happening to the text
	# back quote `` means command substitution
	# matlab -singleCompThread -nodisplay  -r "cd('${MATLAB_SOURCE_PATH}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
	# 					   cd('${MATLAB_SOURCE_PATH_2}'), addpath(genpath(cd)), cd('${PBS_O_WORKDIR}'), \
	# 		               cd('${DATA_DIR}'), ${MATLAB_POST_PROCESS_FUNC}('${OUTPUTFILE}'), exit"
	# the single quote here is for matlab to recognize string
	# the double quote here is for shell to expand macros.


# zip files if mat done # It's NOT safe to use zip in PBS array job!!!!1
# cd ${DATA_DIR};
# matdone=`ls *mat | sed -n '/^'${ID}'-.*mat$/p'| wc -l`;
# if [ "${matdone}" == "1" ]; then
#	echo zipping ygfiles with loop number ${ID}...;
#	zip -T -q -m ${PBS_O_WORKDIR}/${DATA_DIR}/ygfiles ${ID}-*${INPUT_APPENDIX} ${ID}-*${INPUT_APPENDIX}_syn ${ID}-*${OUTPUT_APPENDIX};
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

 
