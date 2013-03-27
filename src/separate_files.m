function separate_files(inputFile)



%% separate filenames into small files
tic
FF = importdata(inputFile);
tempNum = 100;
for fiter = 1 : ceil(numel(FF)/100)
    fID = fopen(['/cluster/home/retinamap/synapseProject/source/synapseDetector/benchmark/deploy/imagenamefiles/deepBorder_' num2str(fiter) '_of_' num2str(ceil(numel(FF)/100)) '.txt'],'w');
    if fiter == ceil(numel(FF)/100)
        tempNum = mod(numel(FF),100);
    end
    for subIter = 1 : min(100,tempNum)
        fprintf(fID,[FF{(fiter-1)*100+subIter} '\n']);
    end
    fclose(fID);
end
toc
