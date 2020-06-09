load('..\data\cameraParams.mat');
f = mean(cameraParams.FocalLength);
s = f;
vec = @(x) x(:);
preallocate = 4000;
warpedImages = cell(1, preallocate);
% Load video
seqDIR = '..\data\';
content = dir(seqDIR);
for i = 1:length(content)
    if regexp(lower(content(i).name), '\.mov$')
        vidName = content(i).name;
        break
    end
end
v = VideoReader([seqDIR vidName]);

% Read the first image from the image set.
I = readFrame(v);

% Initialize features for I(1)
grayImage = rgb2gray(I);
points = detectSURFFeatures(grayImage);
[features, points] = extractFeatures(grayImage, points);
warpedImages{1} = warpCylindrical(I, f);

totx = [];
toty = [];

% Iterate over video
pointsPrevious = points;
featuresPrevious = features;
IPrevious = I;
IPrevious_ = warpCylindrical(IPrevious, f);
[H, W, ~] = size(I);
[H_, W_, ~] = size(IPrevious_);
baseline = 9*25.4;
x0 = W/2; y0 = H/2;
calibrationTilt = 1.5;

n = 1;
loopcount = 0;
figure(10)
hold off
depthx = zeros(H, preallocate); depthy = zeros(H, preallocate); depthZ = zeros(H, preallocate); deptho = zeros(H, preallocate);
depthX = zeros(H, preallocate); depthY = zeros(H, preallocate); depthidx = zeros(H, preallocate);
while hasFrame(v)
    loopcount = loopcount + 1;
    I = readFrame(v);
    
    % detect laser line
    idx = detect_line(I);
    depthidx(:, loopcount) = idx;
    depth = disparity_to_depth(idx, f, baseline, x0, calibrationTilt);
    depth(depth>10000) = nan;
    depth(depth<100) = nan;
    [x, y] = warpCylindrical(idx, (1:H)', f, [H W]);
    depthx(:, loopcount) = x;
    depthy(:, loopcount) = y;
    depthZ(:, loopcount) = depth;
    depthX(:, loopcount) = (idx - x0) .* depth / f;
    depthY(:, loopcount) = ((H:-1:1)' - y0) .* depth / f;
    
    % Convert image to grayscale.
    grayImage = rgb2gray(I);    
    
    % Detect and extract SURF features for I(n).
    points = detectSURFFeatures(grayImage);
    [features, points] = extractFeatures(grayImage, points);
  
    % Find correspondences between I(n) and I(n-1).
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
       
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);
    
    [H, W, D] = size(IPrevious);
    x = matchedPoints.Location(:, 1);
    y = matchedPoints.Location(:, 2);
    xPrev = matchedPointsPrev.Location(:, 1);
    yPrev = matchedPointsPrev.Location(:, 2);
    
    [x_, y_] = warpCylindrical(x, y, f, [H W]);
    [xPrev_, yPrev_] = warpCylindrical(xPrev, yPrev, f, [H W]);
    
    dx = xPrev_ - x_;
    dy = yPrev_ - y_;
    valid = abs(dy)<50;
    my = median(dy(valid));
    mx = median(dx(valid));
    figure(10)
    plot(loopcount, mx, 'kx')
    hold on
    deptho(loopcount) = mx + sum(totx);
    
    if isnan(mx)
        fprintf('skipped frame\n')
        loopcount = loopcount - 1;
        continue
    end
    if (mx > 2*pi*f/24) || mod(loopcount, 40) == 0 || ~hasFrame(v)
        n = n + 1;
        
        totx(n) = mx;
        toty(n) = my;
        
        I_ = warpCylindrical(I, f);
        figure(11)
        hold off
        imagesc(cat(2, IPrevious_, I_));
        hold on
        for i = 1:length(x_)
            if valid(i)
                plot([xPrev_(i) x_(i)+W_], [yPrev_(i) y_(i)], 'w-');
            end
        end
        
        warpedImages{n} = I_;
        pointsPrevious = points;
        featuresPrevious = features;
        IPrevious = I;
        IPrevious_ = I_;
    end 
end
depthx = depthx(:, 1:loopcount); depthy = depthy(:, 1:loopcount); depthZ = depthZ(:, 1:loopcount); deptho = deptho(:, 1:loopcount);
depthX = depthX(:, 1:loopcount); depthY = depthY(:, 1:loopcount); depthidx = depthidx(:, 1:loopcount);
depthZ = filterDepth(depthZ, 7, 0.5);
warpedImages = warpedImages(1:loopcount);

WW = round(sum(totx)) + W_;
panorama = zeros(H_, WW, 3);
for i = n:-1:1
    left = round(sum(totx(1:i))) + 1;
    top = round(sum(toty(1:i))) + 1;
    top = 1;
    im = warpedImages{i};
    panorama(top:H_, left:left+W_-1, :) = im(top:H_, :, :);
end



WW = round(sum(totx)) + W_;
panoramaz = zeros(H_, WW);
for i = 1:loopcount
    o = deptho(i);
    x = depthx(:, i);
    y = depthy(:, i);
    z = depthZ(:, i);
    top = 1;
    for ii = 1:length(x)
        panoramaz(round(y(ii)), round(x(ii)+o)) = z(ii);
    end
end
panoramaz(isnan(panoramaz)) = 0;


xyz = zeros(H, loopcount, 3);
deptha = deptho/f;
rgb = zeros(H, loopcount, 3);
panorama(1920, 1, 1) = 0;
for i = 1:loopcount
    R = rotationMatrix(0, -deptha(i), 0);
    X = depthX(:, i); Y = depthY(:, i); Z = depthZ(:, i);
    xyz(:, i, :) = reshape((R * [X Y Z]')', [H 1 3]);
    
    o = deptho(i);
    x = depthx(:, i);
    y = depthy(:, i);
    for ii = 1:length(x)
        rgb(ii, i, :) = panorama(round(y(ii)), round(x(ii)+o), :);
    end
end
[ii, jj] = size(depthZ);
valid = ones([ii jj]);
valid(depthZ == 0) = nan;
valid(depthZ < 800) = nan;
valid = cat(3, valid, valid, valid);
xyz_ = xyz.*valid;

xyz_ = reshape(xyz_, [H*loopcount 3]);
xyz_ = [xyz_(:,1), -xyz_(:,3), xyz_(:,2)];
rgb_ = reshape(rgb.^(1/2), [H*loopcount 3]);
ptCloud = pointCloud(xyz_, 'Color', uint8(255*rgb_));

if seqDIR(end) == '\' || seqDIR(end) == '/'
    fname = seqDIR(1:end-1);
    k = regexp(fname, '(\\|\/)');
    fname = fname(k(end)+1:end);
end

% pcwrite(ptCloud, [seqDIR [fname '.ply']]) ;

figure(200)
pcshow(ptCloud)
xlabel('x[mm]'); ylabel('y[mm]'); zlabel('z[mm]');
% saveas(gcf, [seqDIR [fname '.fig']])

