addpath(genpath('/cluster/home/vignesh/synapseProject/interfaces/featureComputation/'));
mcc -m featGate.m cbi_bagimg.m ...
extractCooccur.m genBorderMask.m ... 
makeRFSfilters.m vrl_imfilter.m;