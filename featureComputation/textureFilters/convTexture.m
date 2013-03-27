function filtResponse = convTexture(I, F)
    I = double(I);
if( size(F,3) == 38 )
    % I = double( imresize(I, [128 128]) );
    tempResponse = zeros(size(I,1), size(I,2), size(F,3));
    filtResponse = zeros(size(I,1), size(I,2), 8);
    for iter = 1:size(F, 3);
        temp = vrl_imfilter( I, F(:,:,iter));
% % % %         temp = temp - mean(temp(:));
% % % %         temp = temp ./ std(temp(:));
        tempResponse(:, :, iter) = temp;
    end
    % Weber's Law Normalization
    L = repmat( sqrt( sum(tempResponse.^2, 3) ), [1 1 size(F,3)] );
    tempResponse = tempResponse .* log( 1 + L/.03 ) ./ (L+eps);
   
    for iter = 1:6:36
    %    filtResponse(:,:,(iter-1)/6+1) = max( tempResponse(:, :, iter:iter+5), [], 3 );
    end
    %filtResponse(:,:,7) = tempResponse(:,:,37); % subplot(4,2,7); imagesc(filtResponse(:,:,7));
    %filtResponse(:,:,8) = tempResponse(:,:,38); % subplot(4,2,8); imagesc(filtResponse(:,:,8));
    
% % % % % % % % % % % % %     for iter = 1:8
% % % % % % % % % % % % %         resFiltResponse(:,:,iter) = imresize( filtResponse(:,:,iter), [100 100]);
% % % % % % % % % % % % %     end
% % % % % % % % % % % % %     filtResponse = reshape( resFiltResponse, 100*100, 8 );
    
    filtResponse = reshape( tempResponse, size(I,1)*size(I,2), 38 );
    
else % using variant of Leung Malik
    tempResponse = zeros(size(I,1), size(I,2), size(F,3));
    filtResponse = zeros(size(I,1), size(I,2), 8);
    for iter = 1:size(F, 3);
        temp = vrl_imfilter( I, F(:,:,iter));
        tempResponse(:, :, iter) = temp;
    end
    % Weber's Law Normalization
    L = repmat( sqrt( sum(tempResponse.^2, 3) ), [1 1 size(F,3)] );
    tempResponse = tempResponse .* log( 1 + L/.03 ) ./ (L+eps);
    filtResponse = reshape( tempResponse, size(I,1)*size(I,2), size(F,3) );
    % figure(100);
end