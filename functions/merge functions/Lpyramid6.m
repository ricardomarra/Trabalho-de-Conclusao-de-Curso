function [pyramid_cell] = Lpyramid6(myimage)

% Lpyramid6 
%Decomposes an image into 6 layers of a Laplacian Pyramid
%
%   [pyramid_cell] = Lpyramid6(myimage)
%
%Input:
%   myimage: one dimention double image that will be decomposed
%
%Output:
%   pyramid_cell: 6-elements cell with the pyramid layers
%                 layer 1: smallest image    layer 6: largest image


%Primeira parte: tratamento da imagem. 
x = myimage;

%Segunda parte: faz a decomposicao (a piramide)
%Define o filtro e o tamanho.
%A saida eh um cell.
% Laplacian decomposition using 9/7 filters and 5 levels
pfilt = '9/7';
n = 5;
y = lpd(x, '9/7', n);

% Display output
figure
colormap(gray)
nr = floor(sqrt(n+1));
nc = ceil((n+1)/nr);
for l = 1:n+1
    subplot(nr, nc, l); 
    imageshow(y{l});
end

%Terceira parte: Reconstroi a imagem a partir da piramide e do filtro.
% Reconstruction
xr = lpr(y, pfilt);

% Show perfect reconstruction
figure
colormap(gray)
subplot(1,2,1), imageshow(x, [0, 1]);
subplot(1,2,2), imageshow(xr, [0, 1]);
title(sprintf('SNR = %.2f dB', SNR(x, xr)))

%Quarta parte: Volta a imagem para o range de 0 a 255 e uint8
xr2 = uint8(round(xr .* 255));

pyramid_cell = y;

end

