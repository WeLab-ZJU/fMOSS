function class_p_update = classify_connect_domain(para)
%   classift every connect domain into one class

%   label_0: 26-connect domain label of class 0 
%   coor_db: coor of all points(db = debias)
%   blocks: 3 class(layers) blocks
%   class_p: original classify result of all points
%   axis_dire: the norm direction of this area
%   mu: the mu of 3 Gaussian distribution

class_p     = para.class_p;
blocks      = para.blocks;
coor_db     = para.coor_db;
label_0     = para.label_0;
axis_dire   = para.axis_dire;
mu          = para.mu;
num_lys     = para.num_lys;

class_p_update = class_p;
num_cont = max(label_0(:));
near_26 = [
    -1,     -1,     -1;
    0,      -1,     -1;
    1,      -1,     -1;
    -1,     0,      -1;
    0,      0,      -1;
    1,      0,      -1;
    -1,     1,      -1;
    0,      1,      -1;
    1,      1,      -1;
    -1,     -1,     0;
    0,      -1,     0;
    1,      -1,     0;
    -1,     0,      0;
    1,      0,      0;
    -1,     1,      0;
    0,      1,      0;
    1,      1,      0;
    -1,     -1,     1;
    0,      -1,     1;
    1,      -1,     1;
    -1,     0,      1;
    0,      0,      1;
    1,      0,      1;
    -1,     1,      1;
    0,      1,      1;
    1,      1,      1;
    ];
sub_db = coor_db(:, [2 1 3]);
sz = size(label_0);
blank_blk = zeros(size(label_0));

for i = 1:num_cont
    idx_blk = find(label_0 == i);
    [sub_y, sub_x, sub_z] = ind2sub(sz, idx_blk);
    sub = [sub_y sub_x sub_z];
    sub_rp = repmat(sub, 1, 26)';
    sub_rp = sub_rp(:);
    sub_rp = reshape(sub_rp, 3, [])';
    near_26_rp = repmat(near_26, size(sub, 1), 1);
    sub_near = unique(near_26_rp + sub_rp, 'row');
    near_blk = blank_blk;
    near_blk(sub_near(:,1), sub_near(:,2), sub_near(:,3)) = 1;
    cont_flag = zeros(1, num_lys);
    for c = 1:num_lys
        blk_c = blocks{c};
        connect_blk = blk_c .* near_blk;
        if sum(connect_blk(:)) > 0
            cont_flag(c) = 1;
        end
    end
    if sum(cont_flag) == 0
        % calculate the center
        cen_sub = mean(sub, 1);
        cen_coor = cen_sub([2 1 3]);
        vec = cen_coor - coor_db(1, :);
        pj = sum(vec.*axis_dire)/norm(axis_dire);
        [~, close_c] = min(abs(pj - sort(mu)));
        idx_cont = ismember(sub_db, sub, 'row');
        class_p_update(idx_cont) = close_c;
    elseif sum(cont_flag) == 1
        close_c = find(cont_flag == 1);
        idx_cont = ismember(sub_db, sub, 'row');
        class_p_update(idx_cont) = close_c;
    elseif sum(cont_flag) >= 2
        coor_cont = sub(:, [2 1 3]);
        vec = coor_cont - coor_db(1, :);
        pj = sum(vec.*axis_dire, 2)/norm(axis_dire);
        pj_rp = repmat(pj, 1, num_lys);
        [~, close_c] = min(abs(pj_rp - sort(mu)), [], 2);
        idx_cont = ismember(sub_db, sub, 'row');
        class_p_update(idx_cont) = close_c;
    end
    
end


end

