       % Build a grid
       N = 100;
       x = (-N:2:N)/N;
       [X,Y] = meshgrid(x);
       [theta,r] = cart2pol(X,Y);
       
       is_in_circle = r <= 1;
       r = r(is_in_circle);
       theta = theta(is_in_circle);
       
       % Create some data
       F = peaks(N+1);F = F/max(abs(F(:))); % Normalize
       F(~is_in_circle) = nan;
       
       % Compute a (finite) basis of pseudo-Zernike functions
       n_max = 7;
       n = zeros(1,(n_max+1)^2);
       m = zeros(1,(n_max+1)^2);
       for k = 0:n_max
           n(k^2+1:(k+1)^2) = repmat(k,1,2*k+1);
           m(k^2+1:(k+1)^2) = -k:k;
       end
       P = pzernfun(n,m,r,theta);
       
       % Estimate the pseudo-Zernike moments, using simple
       % summation to approxmiate the integrals
       M = zeros(1,(n_max+1)^2);
       for k = 1:(n_max+1)^2
           M(k) = sum(F(is_in_circle)'*P(:,k))*(2/N)^2;
       end
       
       % Use the computed moments to recover the original data
       F_recovered = nan(size(X));
       F_recovered(is_in_circle) = P*M';
       
       % Display the data
       h = figure('Position',[0 0 800 300],'Visible','off');
       axes('Position',[0.05 0.11 0.25 0.8])
       pcolor(x,x,F), shading interp
       set(gca,'XTick',[],'YTick',[])
       axis square
       title('Original')
       
       axes('Position',[0.35 0.11 0.25 0.8])
       pcolor(x,x,F_recovered), shading interp
       set(gca,'XTick',[],'YTick',[])
       axis square
       title(sprintf('Recovered\n(pseudo-Zernike Moments)'))
       
       ha = axes;
       pcolor(x,x,F-F_recovered), shading interp
       set(gca,'XTick',[],'YTick',[])
       axis square
       title('Difference')
       colorbar
       set(ha,'Position',[0.65 0.11 0.25 0.8],'CLim',[min(F(:)) max(F(:))])
       
       movegui(h,'center')
       set(h,'Visible','on')