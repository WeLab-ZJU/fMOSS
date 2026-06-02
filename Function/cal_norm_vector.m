function [normD,normE] = cal_norm_vector(points, kdtree)
%CAL_NORM_VECTOR calculate the norm vector of the surface points
%   

normE = []; % norm vectors
normD = []; % norm direction

p_whol_cent = mean(points, 2);

for i=1:length(points)
    p_cur = points(:,i);
    [index, ~] = vl_kdtreequery(kdtree, points, p_cur, 'NumNeighbors', 20); % N nearest points
    p_neighbour = points(:,index)';
    p_cent = mean(p_neighbour); % 得到局部点云平均值，便于计算法向量长度和方向
    
    % 最小二乘估计平面
    X = p_neighbour(:,1);
    Y = p_neighbour(:,2);
    Z = p_neighbour(:,3);
    XX = [X Y ones(length(index),1)];
    YY = Z;
    % 得到平面法向量
    C = (XX'*XX)\XX'*YY;
    
    % 局部平面指向局部质心的向量
    dir1 = p_cent - p_cur';
    % 局部平面法向量
    dir2 = [C(1) C(2) -1];
    
    % 整体质心指向点的向量
    dir3 = p_cur' - p_whol_cent';
    
    % 计算两个向量的夹角
    cos_12 = sum(dir1.*dir2) / norm(dir1) / norm(dir2);
    cos_23 = sum(dir2.*dir3) / norm(dir2) / norm(dir3);
    % 根据夹角判断法向量正确的指向
    ang_12 = acos(cos_12);
    ang_23 = acos(cos_23);
    dis = 20;
    
    if ang_23 > pi/2
        dir2 = -dir2;
    end
    
    
    % norm vector
    t = (0:dis/100:dis)';
    norm_dir = dir2/norm(dir2);
    normD = [normD; norm_dir];
    x = p_cur(1) + norm_dir(1)*t;
    y = p_cur(2) + norm_dir(2)*t;
    z = p_cur(3) + norm_dir(3)*t;
    
    normE =[normE;x y z];
    fprintf('Processing %d / %d\n', i, length(points));
end



end

