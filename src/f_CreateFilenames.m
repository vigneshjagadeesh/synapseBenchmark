% This script gathers all image files needed for benchmark creator, and 
% stores the filenames into a few .txt files. Those filenames can be used 
% by mainCaller.m in benchmark/
function f_CreateFilenames()


if nargin < 1
    bmark.dataDir = '/cluster/home/retinamap/datasetCreator/utahDataBase/';
    bmark.negFolder     = { 'YAC', 'GAC', 'CBb4', 'CBb5', 'Gly+', 'MG', 'BC', 'CBa2', 'CBab', 'HC' };
    for iter = 1 : numel(bmark.negFolder);     bmark.negFolder{iter} = [bmark.negFolder{iter} '_deep/' ];     end
    bmark.posFolder         = { 'postSynapseDataset/'};
    bmark.posAlignedFolder  = { 'postSynapseDataset/synapseAligned/'};
end

%% finding positive image files larger than .5 MB
fID = fopen('/cluster/home/retinamap/datasetCreator/utahDataBase/filenamesPos.txt','w');
tic
for dirIter = 1 : numel(bmark.posFolder)
    currDir = [bmark.dataDir bmark.posFolder{dirIter} '*.png'];
    tempFiles = dir(currDir);
    for fIter = numel(tempFiles) : -1 : 1
        if tempFiles(fIter).bytes > 5e5
            fprintf(fID, [bmark.dataDir bmark.posFolder{dirIter} tempFiles(fIter).name '\n']);
        end
    end
end
toc
fclose(fID);

%% finding positive aligned image files larger than .5 MB
fID = fopen('/cluster/home/retinamap/datasetCreator/utahDataBase/filenamesPosAligned.txt','w');
tic
for dirIter = 1 : numel(bmark.posAlignedFolder)
    currDir = [bmark.dataDir bmark.posAlignedFolder{dirIter} '*.png'];
    tempFiles = dir(currDir);
    for fIter = numel(tempFiles) : -1 : 1
        if tempFiles(fIter).bytes > 5e5
            fprintf(fID, [bmark.dataDir bmark.posAlignedFolder{dirIter} tempFiles(fIter).name '\n']);
        end
    end
end
toc
fclose(fID);

%% finding negative image files larger than .5 MB

fID = fopen('/cluster/home/retinamap/datasetCreator/utahDataBase/filenamesNegDeep.txt','w');
for dirIter = 1 : numel(bmark.negFolder)
    tic
    currDir = [bmark.dataDir bmark.negFolder{dirIter} '*.png'];
    display(currDir);
    tempFiles = dir(currDir);
    fNum = 0;
    for fIter = numel(tempFiles) : -1 : 1
        if tempFiles(fIter).bytes > 1e6
            fprintf(fID, [bmark.dataDir bmark.negFolder{dirIter}  tempFiles(fIter).name '\n']);
            fNum = fNum+1;
        end
    end
    fNum
    toc
end

fclose(fID);


%% finding negative deepBorder image files larger than .5 MB
fID = fopen('/cluster/home/retinamap/datasetCreator/utahDataBase/filenamesNegDeepBorder.txt','w');
for dirIter = 1 : numel(bmark.negFolder)
    tic
    currDir = [bmark.dataDir bmark.negFolder{dirIter} '*.png'];
    display(currDir);
    tempFiles = dir(currDir);
    fNum = 0;
    for fIter = numel(tempFiles) : -1 : 1
        if tempFiles(fIter).bytes > 5e5
            fprintf(fID, [bmark.dataDir bmark.negFolder{dirIter} tempFiles(fIter).name '\n']);
            fNum = fNum+1;
        end
    end
    fNum
    toc
end


fclose(fID);


%%
tic
tempNum = 100;
inputFile = importdata('/cluster/home/retinamap/datasetCreator/utahDataBase/filenamesNegDeep.txt');
for fIter = 1 : ceil(numel(inputFile)/100)
    fID = fopen(['/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/deploy/imagenamefiles/NegDeep_' num2str(fIter) '.txt'],'w');
    if fIter == ceil(numel(inputFile)/100)
        tempNum = mod(numel(inputFile),100);
    end
    for iter = 1 : tempNum
        fprintf(fID, [inputFile{(fIter-1)*100+iter} '\n']);
    end
    fclose(fID);
end
toc









