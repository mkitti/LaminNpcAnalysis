coords = orientationSpace.getFrequencySpaceCoordinates(1024);
coords.df = fftshift(discretize(coords.f,30));
S_hat_abs2 = abs(fftshift(fft2(ifftshift(S)))).^2;
for i=1:20; test(:,i) = accumarray(coords.df(:),joinColumns(S_hat_abs2(:,:,i)),[],@mean); end;
figure; plot((test./max(test,[],2)).');