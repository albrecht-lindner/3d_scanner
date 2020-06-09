filename = 'anim3d.gif';
n = 0;
for a = 0:10:350
    view([a 30])
    drawnow
    frame = getframe(gcf); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    
    n = n + 1;
    if n == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime', .1); 
    end 
end
for a = 0:10:350
    view([a 50])
    drawnow
    frame = getframe(gcf); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    
    n = n + 1;
    if n == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime', .1); 
    end 
end
