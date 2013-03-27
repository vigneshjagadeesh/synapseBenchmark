function temp1= cutImg(temp1, I)
    [imro imco] = size(I);
    [imr imc] = size(temp1);
    osetr = floor((imr-imro)/2);
    osetc = floor((imc-imco)/2);
    temp1 = temp1(osetr+1:osetr+imro,osetc+1:osetc+imco);

%     rowSum = sum(temp1, 1); colSum = sum(temp1, 2);
%     rowStrt = 1;             while( rowSum(rowStrt) == 0 ), rowStrt = rowStrt  + 1; end
%     colStrt = 1;             while( colSum(colStrt) == 0 ), colStrt = colStrt  + 1; end
%     rowEnd  = numel(rowSum); while( rowSum(rowEnd) == 0 ), rowEnd = rowEnd  - 1; end
%     colEnd  = numel(colSum); while( colSum(colEnd) == 0 ), colEnd = colEnd  - 1; end
%     temp1 = temp1( rowStrt:rowEnd, colStrt:colEnd);
%     temp1 = imresize(temp1, [size(I,1) size(I,2)]);