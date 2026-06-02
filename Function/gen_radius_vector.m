function radius_vector = gen_radius_vector(norm_vector)
%GEN_RADIUS_VECTOR generate radius vector norm with the norm vector
x0 = norm_vector(1);
y0 = norm_vector(2);
z0 = norm_vector(3);
radius_vector = [];
R_vec = [
    -y0 x0 0;
    y0 -x0 0;
    -z0 0 x0
    z0 0 -x0
    0 -z0 y0
    0 z0 -y0];

R_vec = R_vec./sqrt(sum(R_vec.^2, 2));
vec_1 = R_vec(1, :);
vec_2 = R_vec(3, :);

proj_21 = sum(vec_1.*vec_2)* vec_1;
vec_v = vec_2 - proj_21;
vec_v = vec_v/norm(vec_v);


for i = -1:0.3:1
    for j = -1:0.3:1
        vec_s = i * vec_1 + j* vec_v;
        radius_vector = [radius_vector;vec_s];
    end
end



end

