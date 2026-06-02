%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 20260109
% Author: zjuzjz
% Email: [3160100534@zju.edu.cn]
% Note: -
% Version: -
% Change Log: -
% Function: Vessel contour extraction using alpha shape algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% initialize
clc; close all; clear;
addpath('./Function');

%% load skeleton point set
data_path = './Data/';
skel = load([data_path, 'data_skeleton.mat']);
coord_skel = skel.coord;

x = coord_skel(:, 1);
y = coord_skel(:, 2);
z = coord_skel(:, 3);

%% visualization of retinal vascular surface
[k2, av2] = convhull(x, y, z, 'Simplify', true);

figure('Name', 'Mesh Grid');
trisurf(k2, x, y, z,'FaceColor','cyan');
axis equal;
set(gcf, 'color', 'w');
title('Mesh Grid', 'color', 'k', 'Fontsize', 20);


%% alpha shape algorithm
figure('Name', 'Alpha shape');
shp = alphaShape(x, y, z, 45);
tri = alphaTriangulation(shp);
plot(shp, 'FaceColor','#a37b05', 'LineStyle','none', ...
    'DisplayName', 'Surface');hold on;
plot3(x,y,z, '.','markersize', 10, 'color', [249,209,253]/255, ...
    'DisplayName', 'Points on the surface');
legend();

xlabel('X axis');ylabel('Y axis');zlabel('Z axis');
axis equal;
set(gcf, 'color', 'w');set(gca, 'color', 'w');
grid on;
title('Alpha shape', 'FontSize', 20, 'color', 'k');

%%  check and save the coordinate of the surface point
ply_dir = [data_path 'surface.ply'];
pot_dir = [data_path 'surface_points.mat'];
faces = shp.boundaryFacets;
point_surf = unique(faces);
points = shp.Points(point_surf, :);
coor_surf = [x(point_surf) y(point_surf) z(point_surf)];
idx = 1:size(point_surf, 1);
faces_surf = zeros(size(faces));
for i = 1:size(faces, 1)
    for j = 1:size(faces, 2)
        n = find(point_surf == faces(i, j));
        faces_surf(i, j) = n;
    end
end

write_ply(points, faces_surf, ply_dir, 'ascii');
save(pot_dir, 'points'); % [X Y Z]

%%
