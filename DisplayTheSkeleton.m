%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 20260109
% Author: zjuzjz
% Email: [3160100534@zju.edu.cn]
% Note: need RAM ≥ 32GB
% Version: -
% Change Log: -
% Function: Convert the three-dimensional skeleton image of retinal 
% vasculature into a coordinate point set and display it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initialize
clc; close all; clear;
addpath('./Function');
data_path = './Data/';

%% load skeleton image of retinal vasculature
im = read_tif([data_path, 'mouse_eye.tif']);

%% coordinate point set
ind = find(im > 0);
imSz = size(im);

[y, x, z] = ind2sub(imSz, ind);
coord = [x, y, z];
boxSize = [imSz(2), imSz(1), imSz(3)];

save([data_path, 'data_skeleton.mat'], 'coord', 'boxSize');

%% display
skel = load([data_path, 'data_skeleton.mat']);
coord_skel = skel.coord;
figure('Name', 'Mouse eye: skeleton');
pcshow(coord_skel);
title('Mouse eye: skeleton', 'w', 'FontSize', 20);

%%


