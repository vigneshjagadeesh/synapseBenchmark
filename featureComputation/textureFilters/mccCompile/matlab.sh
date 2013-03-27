#!/bin/sh
#
# Filename: matlab.sh
#
# ./matlab.sh "simplesleep(10,2,'output.txt')"
#

# run matlab in text mode 
#exec /cluster/home/matlab_2009a_x86_64/bin/matlab  -nojvm -nodisplay -nosplash -r "$*"
export LD_LIBRARY_PATH=/cluster/home/matlab_2011a/bin/glnxa64/:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/cluster/home/matlab_2011a/runtime/glnxa64/:$LD_LIBRARY_PATH
exec /cluster/home/vignesh/synapseProject/interfaces/featureComputation/textureFilters/mccCompile/featGate ${1} ${2}
exit 0
