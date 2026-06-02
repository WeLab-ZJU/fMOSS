%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 20260109
% Author: zjuzjz
% Email: [3160100534@zju.edu.cn]
% Note: -
% Version: -
% Change Log: -
% Function: Layer separation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initialize
clear;close all;clc;
warning off;
run('./Function/vlfeat/toolbox/vl_setup');
addpath('./Function/');
data_path = './Data/';

%% load plexus data
coord_pl_path = [data_path, 'coord_pl.mat'];
if exist(coord_pl_path, 'file')
    coord_pl = load(coord_pl_path).coord_pl;
else
    im_plexus = read_tif([data_path, 'plexus.tif']);
    ind_pl = find(im_plexus > 0);
    [y, x, z] = ind2sub(size(im_plexus), ind_pl);
    coord_pl = [x, y, z]';
    save([data_path, 'coord_pl.mat'], 'coord_pl');
end

%% load surface points
kdtree_pl = vl_kdtreebuild(coord_pl);
figure('Name','Plexus vesseel');
pcshow(pointCloud(coord_pl'));
title('Plexus vessel', 'color', 'w', 'FontSize', 20);

%% calculate the normal vector on surface points
% norm_file_path = [data_path 'norm_file.mat'];
% if ~exist(norm_file_path, 'file')
%     surf_dir = [data_path 'surface_points.mat'];
%     pc_surf = load(surf_dir).points;
%     pc_ds = pcdownsample(pointCloud(pc_surf),'random',0.6);
% 
%     figure('Name','PC_DownSample','NumberTitle','off');
%     pcshow(pc_ds);
% 
%     pc_point_ds = pc_ds.Location';
%     kdtree_ds = vl_kdtreebuild(pc_point_ds);
% 
%     [normD, normE] = cal_norm_vector(pc_point_ds, kdtree_ds);
%     save(norm_file_path, 'normD', 'normE', 'pc_point_ds', 'kdtree_ds', 'pc_ds');
% else
%     load(norm_file_path);
% end
% pc_rescale = pointCloud(pc_point_ds');
% figure('Name','PC_DownSample & Norm Vector','NumberTitle','off');
% pcshowpair(pc_rescale, pointCloud(normE));
% disp('Normal calculate finished...');

surf_dir = [data_path 'surface_points.pcd'];
pc_surf = pcread(surf_dir);
verts_normals = load([data_path, 'verts_normals.mat']).verts_normals;

cen = mean(pc_surf.Location);
dire1 = pc_surf.Location - cen;
dire2 = verts_normals;
v = sum(dire1.*dire2, 2);
verts_normals(v>0, :) = -verts_normals(v>0, :);

pc_point_ds = pc_surf.Location';
normD = verts_normals;
kdtree_ds = vl_kdtreebuild(pc_point_ds);

dis = 20;
% Create parameter t for all lines at once (0 to dis with step dis/100)
t = (0:dis/100:dis)';
num_t = length(t);

% Get dimensions
N = size(pc_point_ds, 2); % Number of points

% Normalize all normal directions at once
norm_magnitudes = sqrt(sum(normD.^2, 2)); % Calculate magnitudes
normD_normalized = normD ./ norm_magnitudes; % Normalize each vector

% Reshape points and normals to prepare for broadcasting
points = pc_point_ds'; % N×3 matrix of points
normals = normD_normalized; % N×3 normalized normals

% Prepare for broadcasting operation
points_expanded = reshape(points, [N, 1, 3]); % N×1×3
normals_expanded = reshape(normals, [N, 1, 3]); % N×1×3
t_expanded = reshape(t, [1, num_t, 1]); % 1×num_t×1

% Broadcast to compute all line points at once
% This creates an N×num_t×3 array where each entry [i,j,k] is:
% point[i,k] + normal[i,k] * t[j]
line_points = points_expanded + normals_expanded .* t_expanded;

% Reshape to get the final result
normE = reshape(permute(line_points, [2, 1, 3]), [], 3);

figure('Name','PC_DownSample & Norm Vector','NumberTitle','off');
pcshowpair(pointCloud(pc_point_ds'), pointCloud(normE));
disp('Normal calculate finished...');

%% GMM to separate SP/IP/DP vessels
time_start = tic;
num_lys = 3;
class_plexus = zeros(1, size(coord_pl, 2));
for cpc = 2:6:size(pc_point_ds, 2)
    if mod(cpc, 1000) ==0
        fprintf('CPC process %d/%d...\n', cpc, size(pc_point_ds, 2));
    end
    cen_point_coor = pc_point_ds(:, cpc)';
    idx_nearest_ds =  vl_kdtreequery(kdtree_ds, pc_point_ds, single(cen_point_coor'), 'NumNeighbors', 1);
    
    % idx_nearest_pl =  vl_kdtreequery(kdtree_pl, coord_pl, double(cen_point_coor'), 'NumNeighbors', 1);
    % idx_nearest = find(ismember(pc_point_ds', cen_point_coor, 'rows'));

    if isempty(idx_nearest_ds)
        disp('Point not exist...');
        return;
    end

    axis_dire = normD(idx_nearest_ds, :);
    % center_axis = -100:2:100;
    % centers = center_axis' * axis_dire + cen_point_coor;
    radius = 50;
    % point_cyl = [];
    % 
    % R_vec = gen_radius_vector(axis_dire);
    % 
    % for i = 1:size(centers, 1)
    %     cen = centers(i, :);
    %     R_vec = R_vec./sqrt(sum(R_vec.^2, 2)) * radius;
    %     point_cyl = [point_cyl;R_vec + cen];
    % end

    % figure('Name','PC_DownSample & Cylinder Range','NumberTitle','off');
    % pcshowpair(pc_rescale, pointCloud(point_cyl));

    % ***** Calculate the density ***** %
    L_near = 5000;
    idx_point_in = [];
    point_in = [];
    [index, distance] = vl_kdtreequery(kdtree_pl, coord_pl, double(cen_point_coor)', 'NumNeighbors', L_near);
    

    vector_cen2near = coord_pl(:, index)' - cen_point_coor;
    vector_axis = axis_dire;
    theta_vectors = acos(sum(vector_cen2near.*vector_axis, 2) ./ vecnorm(vector_cen2near, 2, 2) /norm(vector_axis));
    distance_axis = vecnorm(vector_cen2near, 2, 2) .* sin(theta_vectors);
    point_in = coord_pl(:, index(distance_axis <= radius))';
    idx_point_in = index(distance_axis <= radius)';
    

    % for i = 1:L_near
    %     vec_1 = coord_pl(:, index(i))' - cen_point_coor;
    %     vec_2 = axis_dire;
    %     theta = acos(sum(vec_1.*vec_2)/norm(vec_1)/norm(vec_2));
    %     dis_axis = norm(vec_1)*sin(theta);
    %     if dis_axis <= radius
    %         point_in = [point_in; coord_pl(:, index(i))'];
    %         idx_point_in = [idx_point_in index(i)];
    %     end
    % end
    %
    % figure('Name','PC_in Cylinder & Norm Vector','NumberTitle','off');
    % pcshowpair(pointCloud(point_in), pointCloud(point_cyl));

    % Print the density
    % density = size(point_in, 1)/(pi * radius^2 *1.75^2);
    % fprintf('The density of vessel: %.4f\n', density);

    % ***** Plot Projection ***** %
    LW = 'linewidth';
    lw = 2;
    proj_l = [];

    vector_cen2point = point_in - cen_point_coor;
    proj_l = (sum(vector_cen2point.*axis_dire, 2) ./ norm(axis_dire))';

    % for i = 1:size(point_in, 1)
    %     vec_p = point_in(i, :) - cen_point_coor;
    %     pj = sum(vec_p.*axis_dire)/norm(axis_dire);
    %     proj_l = [proj_l pj];
    % end

    % figure('Name','Points in Cylinder Projection','NumberTitle','off');
    % hist_fig = histogram(proj_l, 100);
    % figure('Name','GMM Model','NumberTitle','off');
    % hold on;

    try
        GMModel = fitgmdist(proj_l', 3);
        value = linspace(min(proj_l), max(proj_l), 1000);
        sigma = [GMModel.Sigma(:,:,1) GMModel.Sigma(:,:,2) GMModel.Sigma(:,:,3)];
        g1 = 1/sqrt(2*pi)/sqrt(sigma(1)) * gaussmf(value, [sqrt(sigma(1)) GMModel.mu(1)]);
        g2 = 1/sqrt(2*pi)/sqrt(sigma(2)) * gaussmf(value, [sqrt(sigma(2)) GMModel.mu(2)]);
        g3 = 1/sqrt(2*pi)/sqrt(sigma(3)) * gaussmf(value, [sqrt(sigma(3)) GMModel.mu(3)]);

        % plot(value, GMModel.ComponentProportion(1)*g1, LW, lw);
        % plot(value, GMModel.ComponentProportion(2)*g2, LW, lw);
        % plot(value, GMModel.ComponentProportion(3)*g3, LW, lw);
        % stem(hist_fig.BinEdges(1:end-1), hist_fig.Values/length(proj_l));
        % hold off;

        % ***** Divide the layer 1.5 std ***** % 
        mu = GMModel.mu';
        std_glm = sqrt(sigma);
        times_std = 1.5;
        class_p = zeros(1, length(proj_l));
        % ***** adjust the order of the points ***** %
        [~, pos_od] = sort(mu);
        left_p = mu(pos_od) - times_std * std_glm(pos_od);
        righ_p = mu(pos_od) + times_std * std_glm(pos_od);
        while left_p(2) < righ_p(1) || left_p(3) < righ_p(2)
            % disp('Overlapping range...');
            times_std = times_std - 0.1;
            left_p = mu(pos_od) - times_std * std_glm(pos_od);
            righ_p = mu(pos_od) + times_std * std_glm(pos_od);
        end
        for i = 1:3
            class_p(proj_l >= left_p(i) & proj_l <= righ_p(i)) = i;
        end

        % plot_class_points(class_p, point_in);

        % ***** Classify other points ***** %
        % ***** coor:[xyz] // index: [yxz] ***** % 
        [block_0, blocks, coor_db] = coor_debias(point_in, class_p);
        [label_0, volume_0] = label3d_26(block_0);
        para_cd.class_p = class_p;
        para_cd.blocks = blocks;
        para_cd.coor_db = coor_db;
        para_cd.label_0 = label_0;
        para_cd.axis_dire = axis_dire;
        para_cd.mu = mu;
        para_cd.num_lys = num_lys;
        class_p_update = classify_connect_domain(para_cd);
        % plot_class_points(class_p_update, point_in);
        % class_p_update = gmm_classify(proj_l);
        class_plexus(idx_point_in) = class_p_update;
    catch
        fprintf('Meet GMM wrong...cpc = %d\n', cpc);
    end
end
time_consume = toc(time_start);
fprintf('Divide Layers finished. Consume %.2f h\n', time_consume / 3600);

%% display the whole SP/IP/DP vessels
figure('Name', 'SP & IP & DP', 'Position', [0, 400 1500, 600]);
coord_SP = coord_pl(:, class_plexus == 3)';
coord_IP = coord_pl(:, class_plexus == 2)';
coord_DP = coord_pl(:, class_plexus == 1)';
subplot(131);
pcshow(coord_SP, repmat([1.000 0.663 0.251], length(coord_SP), 1));
title('Superficial plexus (SP) vessel', 'color', 'w', 'FontSize', 20);
subplot(132);
pcshow(coord_IP, repmat([0.729 0.902 0.216], length(coord_IP), 1));
title('Intermediate plexus (IP) vessel', 'color', 'w', 'FontSize', 20);
subplot(133);
pcshow(coord_DP, repmat([0.251 0.663 1.000], length(coord_DP), 1));
title('Deep plexus (DP) vessel', 'color', 'w', 'FontSize', 20);

%% save the result of layer separation
class_plexus_path = [data_path 'class_plexus.mat'];
save(class_plexus_path, 'class_plexus');


