function plot_estimate(estimates)
% Plot the estimates as Polyhedra. Requires the mpt3 package. See the
% README file.

    figure();
    hold on;
    for i=1:size(estimates,2)
        P = Polyhedron('V', estimates(i).Vertices, 'R', estimates(i).Rays);
        P.plot('color', 'lightgreen');
    end
    xlabel('$\theta_1$');
    ylabel('$\theta_2$');
    zlabel('$\theta_3$');
    limsy=get(gca,'YLim');
    set(gca,'Ylim',[0 limsy(2)]);
    limsx=get(gca,'XLim');
    set(gca,'Xlim',[0 limsx(2)]);
end


