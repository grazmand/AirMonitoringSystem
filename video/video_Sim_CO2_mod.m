function [] = video_Sim_CO2_mod(rate_video_2,col_step_start,col_step_centr,col_steps_tot,Utot,xxx,yyy,M,Mcolor,XI,YI,ZI,videoFolder)


%% Movie Test 2.
disp('-> video 2')

fid2 = figure('units','normalized','outerposition',[0 0 1 1]);

%% Set up the movie.
vidObj = VideoWriter(fullfile(videoFolder,'Field_2.avi'));
vidObj.Quality = 100;
vidObj.FrameRate = rate_video_2;
open(vidObj);

for k = col_step_start:col_step_centr:col_steps_tot
    
    pause(0.5);
    
    Minimum = min( min(Utot) );
    Maximum = max( max(Utot) );
    levels = Minimum:( Maximum - Minimum )/100:Maximum;
    
    set(gca,'nextplot','replacechildren');
    
    figure(fid2);
    
    hold off
    
    imagesc(xxx,yyy,M);
    shading flat;
    colormap(Mcolor);
    
    ax = gca();
    freezeColors(ax);
    hold(ax, 'on');
    
    contourf(XI,YI,ZI{k},levels,'LineStyle','none','LineColor',[0 0 0]);
    ylabel('Latitude coordinate 43.78 (deg)');
    xlabel('Longitude coordinate 11.22 (deg)');

    h_colorbar = colorbar();
    caxis([Minimum Maximum])
    
    ylabel(h_colorbar, 'CO2 Concentration Levels (ppm)')
    colormap(hsv)
    
    title(sprintf('Concentration map CO2 ppm - step %d - mean = %.2f ppm',k-1,mean(Utot(:,k))));
    drawnow('expose');
    axis equal;
    
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
    
end

close(vidObj);

end

