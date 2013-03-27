function tester(fileName)
I = imread(fileName);
imwrite(I, '/cluster/home/vignesh/testerOutput.png');
