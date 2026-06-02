function cls = gmm_classify(proj_l)
%GMM_CLASSIFY 此处显示有关此函数的摘要
%   此处显示详细说明

GMModel = fitgmdist(proj_l', 3);


mu = GMModel.mu';
[~, idx_order] = sort(mu);
mu_order = mu(idx_order);

sigma = [GMModel.Sigma(:,:,1) GMModel.Sigma(:,:,2) GMModel.Sigma(:,:,3)];
sigma_order = sigma(idx_order);

k = GMModel.ComponentProportion;
k_order = k(idx_order);

p1 = normpdf(proj_l, mu_order(1), sigma_order(1)) * k_order(1);
p2 = normpdf(proj_l, mu_order(2), sigma_order(2)) * k_order(2);
p3 = normpdf(proj_l, mu_order(3), sigma_order(3)) * k_order(3);

[~, cls] = max([p1;p2;p3]);


end

