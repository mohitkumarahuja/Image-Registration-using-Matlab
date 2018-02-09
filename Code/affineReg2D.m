function [ Iregistered, M] = affineReg2D( Imoving, Ifixed )
%Example of 2D affine registration
%   Robert Martí  (robert.marti@udg.edu)
%   Based on the files from  D.Kroon University of Twente 

% clean
clear all; close all; clc;

% Read two imges 
Imoving=im2double(rgb2gray(imread('brain2.png'))); 
Ifixed=im2double(rgb2gray(imread('brain1.png')));

% Smooth both images for faster registration
ISmoving=imfilter(Imoving,fspecial('gaussian'));
ISfixed=imfilter(Ifixed,fspecial('gaussian'));

mtype = 'sd'; % metric type: s: ssd m: mutual information e: entropy 
ttype = 'r'; % rigid registration, options: r: rigid, a: affine

% Parameter scaling of the Translation and Rotation
scale=[1 1 1 1 1 1];

% Set initial affine parameters
x=[1 0 0 0 1 0];

x=x./scale;
    
[x]=fminunc(@(x)affine_function(x,scale,ISmoving,ISfixed,mtype),x,optimset('Display','iter','MaxIter',1000, 'TolFun', 1.000000e-06,'TolX',1.000000e-06, 'MaxFunEvals', 1000*length(x)));
%[x]=fminsearch(@(x)affine_function(x,scale,Im,If,mtype,ttype),x,optimset('Display','iter','MaxIter',1000,'Algorithm','interior-point', 'TolFun', 1.000000e-20,'TolX',1.000000e-20, 'MaxFunEvals', 1000*length(x)));

% Scale the translation, resize and rotation parameters to the real values
x=x.*scale;

% Make the affine transformation matrix
%  M=[ cos(x(3)) sin(x(3)) x(1);
%      -sin(x(3)) cos(x(3)) x(2);
%  	0 0 1]; 

M=[ x(1) x(2) x(3);
    x(4) x(5) x(6);
 	0 0 1];

% Transform the image 
Icor=affine_transform_2d_double(double(Imoving),double(M),0); % 3 stands for cubic interpolation

% Show the registration results
figure,
    subplot(2,2,1), imshow(Ifixed);
    subplot(2,2,2), imshow(Imoving);
    subplot(2,2,3), imshow(Icor);
    subplot(2,2,4), imshow(abs(Ifixed-Icor));

end

