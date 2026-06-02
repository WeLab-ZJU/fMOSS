function plot_class_points(class, points, fig_on)
%PLOT_CLASS_POINTS 
%   

LW = 'linewidth';
lw = 2;

if fig_on
    figure('Name','Clasify','NumberTitle','off');
else
    title('Clasify', LW, lw);
end
hold on;
LG = {};
for i = unique(class)
    idx = class == i;
    plot3(points(idx, 1), points(idx, 2), points(idx, 3), '.', 'markersize', 15);
    if i == 0
        LG = [LG 'Other'];
    else
        ly = ['layer ' num2str(i)];
        LG = [LG ly];
    end
end
axis equal;
grid on;
hold off;
legend(LG);


end

