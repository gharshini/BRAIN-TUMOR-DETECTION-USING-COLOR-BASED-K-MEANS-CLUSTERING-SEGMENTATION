
clc;
clear all;
close all;

Img1=imread('image1.bmp');

Img = double(Img1(:,:,1));

NumIter = 250; %iterations

timestep=0.1; %time step

mu=0.1/timestep;% 
sigma = 5;%
epsilon = 1;
c0 = 2; %  
lambda1=1.0;%outer weight,
lambda2=1.0;%inner weight
nu = 0.001*255*255;%length term
alf = 20;%


figure,imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal
[Height Wide] = size(Img);
[xx yy] = meshgrid(1:Wide,1:Height);
phi = (sqrt(((xx - 90).^2 + (yy - 84).^2 )) - 11);
phi = sign(phi).*c0;


Ksigma=fspecial('gaussian',round(2*sigma)*2 + 1,sigma); %  kernel
ONE=ones(size(Img));
KONE = imfilter(ONE,Ksigma,'replicate');  
KI = imfilter(Img,Ksigma,'replicate');  
KI2 = imfilter(Img.^2,Ksigma,'replicate'); 

figure,imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal,
hold on,[c,h] = contour(phi,[0 0],'r','linewidth',1); hold off
pause(0.5)

tic
for iter = 1:NumIter
    phi =evolution_LGD(Img,phi,epsilon,Ksigma,KONE,KI,KI2,mu,nu,lambda1,lambda2,timestep,alf);

    if(mod(iter,10) == 1)
        figure(2),
        imagesc(uint8(Img),[0 255]),colormap(gray),axis off;axis equal,title(num2str(iter))
        hold on,[c,h] = contour(phi,[1 1],'r','linewidth',1); hold off
        pause(0.01);
    end

end
toc

figure,
imshow(phi);


