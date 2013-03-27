import os
import re
import xml.etree.ElementTree
import shutil
dirName = ['/cluster/data/synapseDataset/synapseDataset/conventional/conSynS1/','/cluster/data/synapseDataset/synapseDataset/ribbon/ribSynS1/','/cluster/data/synapseDataset/synapseDataset/random/randPatS1/'];
feat=['gaborwavelets','textonEnergy','texton','morph1','morph2','gist','lbp','lbpr','ray','radon','zernike','cfmt','coOccur'];
#feat=['gaborwavelets'];
ctr = 0;
dirctr = 0;
for currDir in dirName:
	currFiles = os.listdir(dirName[dirctr]);
	dirctr = dirctr + 1;
	for featIter in range(1,12):
		os.system('mkdir ' + currDir + feat[featIter] + '/');
		shutil.copyfile('generic.condor', 'curr_script' + str(ctr) + '.condor')
		fc = open('curr_script' + str(ctr) + '.condor', 'a')
		fc.write('\nOutput = $(OutputDir)/output.' + str(ctr) + '\n' )
		fc.write('\nError = $(OutputDir)/err.' + str(ctr) + '\n' )
		fc.write('Log = $(OutputDir)/log.' + str(ctr) + '\n' )
		fc.write( 'Arguments =' + currDir + ' ' + str(featIter+1) + '\n')
		fc.write( 'Queue' '\n')
		fc.close()
		os.system('condor_submit curr_script' + str(ctr) + '.condor')
		ctr = ctr + 1		
