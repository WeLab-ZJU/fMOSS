function [block_0, blocks, coor_db] = coor_debias(points, label)
    min_p = min(points);
    max_p = max(points);
    sz_xyz = max_p - min_p + 1;
    coor_db = points - min_p + 1 + 2; % padding 2 
    blocks = {};
    for i = unique(label)
        blk = zeros(sz_xyz(2) + 4, sz_xyz(1) + 4, sz_xyz(3) + 4);
        index = coor_db(:, [2 1 3]);
        sub = sub2ind(size(blk), index(label == i, 1), index(label == i, 2),index(label == i, 3));
        blk(sub) = 1;
        if i == 0
            block_0 = blk;
        else
            blocks = [blocks blk];
        end
    end
    

end

