function stack = read_tif( filename )
%READ_TIF 读取多帧的Tif灰度图
%   filename:文件名
%   stack:图片矩阵Height x Width x Depth

info = imfinfo(filename);
frames = numel(info);
% 16位图或者8位图
if info(1).BitDepth == 16
    stack = (zeros(info(1).Height,info(1).Width, frames, 'uint16'));
elseif info(1).BitDepth == 8
    stack = uint8(zeros(info(1).Height,info(1).Width, frames, 'uint8'));
end

for k = 1:frames
    stack(:, :, k) = single(imread(filename, k));
end

end

