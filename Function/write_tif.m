function write_tif(stack, filename)
%WRITE_TIFF 此处显示有关此函数的摘要
%   将三维数组写为多帧的tif图像
im = Tiff(filename, 'w');

infostruct.ImageLength = size(stack, 1);
infostruct.ImageWidth = size(stack, 2);
infostruct.Photometric = Tiff.Photometric.MinIsBlack;
infostruct.BitsPerSample = 16;
infostruct.SampleFormat = Tiff.SampleFormat.UInt;
infostruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

for k = 1:size(stack, 3)
    im.setTag(infostruct)
    im.write(uint16(stack(:, :, k)));
    im.writeDirectory();
end

im.close();

end

