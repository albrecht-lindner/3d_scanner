function dep = disparity_to_depth(disp, focal_length, baseline, x0, tilt)
H = length(disp);
delta = (0:H-1) - (H-1)/2;
delta = tand(tilt)*delta';

dep = focal_length * baseline ./ (x0 - disp - delta);
