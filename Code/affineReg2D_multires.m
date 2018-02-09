function [ Iregistered, M] = affineReg2D_multires( para)
%this function evaluates 2D registration with multi resolution
%Example of 2D affine registration
%   Robert Martí  (robert.marti@udg.edu)
%   Based on the files from  D.Kroon University of Twente

% clean
clc;

% Read two imges
Imoving=im2double(rgb2gray(imread('brain2.png')));
Ifixed=im2double(rgb2gray(imread('brain1.png')));

% Smooth both images for faster registration
ISmoving=imfilter(Imoving,fspecial('gaussian'));
ISfixed=imfilter(Ifixed,fspecial('gaussian'));

mtype = 'sd'; % metric type: sd: ssd m: mutual information e: entropy
ttype = 'a'; % rigid registration, options: r: rigid, a: affine







% Set initial affine parameters
x=[0.0 0.0 1.0 0.0 0.0 1.0 ];

for mr = para:-1:0
    ISmoving1 = imresize(ISmoving,(1/2^mr));
    ISfixed1 = imresize(ISfixed,(1/2^mr));
    
    % Parameter scaling of the Translation and Rotation
    scale=6*[0.1 0.1 0.1  0.1 0.1 0.1 ];
    
    % Set initial affine parameters
    % x=[0.0 0.0 1.0 0.0 0.0 1.0 ];
    
    x=x./scale;
    
    [x]=fminunc(@(x)affine_function(x,scale,ISmoving1,ISfixed1,mtype,ttype),x,optimset('Display','iter','MaxIter',1000, 'TolFun', 1.000000e-06,'TolX',1.000000e-06, 'MaxFunEvals', 1000*length(x)));
    %[x]=fminsearch(@(x)affine_function(x,scale,ISmoving,ISfixed,mtype,ttype),x,optimset('Display','iter','MaxIter',1000,'Algorithm','interior-point', 'TolFun', 1.000000e-20,'TolX',1.000000e-20, 'MaxFunEvals', 1000*length(x)));
    
    % Scale the translation, resize and rotation parameters to the real values
    x=x.*scale;
    
end

M=[ x(3) x(4) x(1);
    x(5) x(6) x(2);
    0 0 1];

% Transform the image
Icor=affine_transform_2d_double(double(ISmoving),double(M),0); % 3 stands for cubic interpolation

% end

% Show the registration results
figure,
subplot(2,2,1), imshow(Ifixed); title('fixed img')
subplot(2,2,2), imshow(Imoving); title('Moving img')
subplot(2,2,3), imshow(Icor); title('transformed img')
subplot(2,2,4), imshow(abs(Ifixed-Icor)); title('diff img')

end