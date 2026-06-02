function [label, volume] = label3d_26(bw)
%   对3D的图像进行连通域标记
%   bw:输入的二值图
%   label:输出结果，与输入等大小，用同一数值表示同一连通域
%   volume:计算每个连通域的体积大小
volume = [];                          % 每一个连通域的体积
[M, N, D] = size(bw);                 % 待分类图                
label = zeros(M, N, D);               % 分类结果
class = 0;                            % 类别
stopflag = 0;                         % 停止标记
cp = 1;                               % 遍历起始点
stack = zeros(floor(M * N * D/2), 3,'uint16');   % 缓存栈
stackidx = 0;
%% 26邻域
index_y = repmat([-1,0,1], 1,9);
index_x = repmat([-1,-1,-1,0,0,0,1,1,1], 1,3);
index_z = [repmat([-1], 1,9), repmat([0], 1,9), repmat([1], 1,9)];
neib = [index_y;index_x;index_z]';
neib(14, :) = [];

while 1
    % 寻找种子点
    for k = cp:M*N*D
        if bw(k)
            z = ceil(k/M/N);
            y = ceil((k-(z-1)*M*N)/M);
            x = k-(z-1)*M*N-(y-1)*M;
            stackidx = stackidx+1;
            stack(stackidx, :) = [x,y,z];
            class = class+1;
            label(x,y,z) = class;
            volume_class = 1;
            bw(x,y,z) = 0;
            cp = k+1;
            break;
        end
        if k == M*N*D
            stopflag = 1;
        end
    end
    % 结束
    if stopflag
        break;
    end
    % 连通域
    while stackidx
        x = stack(stackidx,1);
        y = stack(stackidx,2);
        z = stack(stackidx,3);
        stackidx = stackidx-1; % 出栈
        for n = 1:size(neib, 1)
            dx = x+neib(n,1);
            dy = y+neib(n,2);
            dz = z+neib(n,3);
            if dx<1||dx>M||dy<1||dy>N||dz<1||dz>D
                break;
            end
            if bw(dx,dy,dz)
                stackidx = stackidx+1; %入栈
                stack(stackidx,:) = [dx,dy,dz];
                bw(dx,dy,dz) = 0;
                label(dx,dy,dz) = class;
                volume_class = volume_class + 1;
            end
        end
    end
    volume = [volume; volume_class];
end

end
