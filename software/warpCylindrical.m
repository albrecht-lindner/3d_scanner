function varargout = warpCylindrical(varargin)
% (out[, xout, yout]) = warpCylindrical(im, f[, s])
% (x_, y_) = warpCylindrical(x, y, f, size[, s])

if nargout == 1 || nargout == 3
    doImage = true;
    im = varargin{1};
    f = varargin{2};
    if nargin == 3
        s = varargin{3};
    else
        s = f;
    end
else
    doImage = false;
    x = varargin{1};
    y = varargin{2};
    if numel(x) ~= numel(y)
        error('x and y must have same number of elements');
    end
    if ~all(size(x) == size(y))
%         warning('reshaping y to the size of x');
        y = reshape(y, size(x));
    end
    f = varargin{3};
    sz = varargin{4};
    if nargin == 5
        s = varargin{5};
    else
        s = f;
    end
end

isPixelCoordinates = true;
if doImage
    [H, W, D] = size(im);
    [x, y] = meshgrid(1:W, 1:H);
else
    H = sz(1); W = sz(2);
    if H*W == 0
        % if height or width is set to zero, the coodinates are assumed to
        % be centered around zero instead of being pixel coordinates
        isPixelCoordinates = false;
    end
end
W2 = (W-1)/2;
H2 = (H-1)/2;
if isPixelCoordinates
    % center coordinates
    x = x - 1 - W2;
    y = y - 1 - H2;
    
end

% conversion to cylindrical coordinates
x_ = s * atan(x/f);
y_ = s * y./sqrt(x.^2 + f^2);
xmin = s * atan(-W2/f);
ymin = s * -H2./sqrt(f^2);
    
if doImage
    % nearest neighbor interpolation
    x_ = round(x_);
    y_ = round(y_);
    xmin = round(xmin);
    ymin = round(ymin);
end

if isPixelCoordinates
    % un-center coordinates back to pixel coordinates
    x_ = x_ - xmin + 1;
    y_ = y_ - ymin + 1;
end

if doImage
    H = max(y_(:));
    W = max(x_(:));
    out = zeros(H, W, D);
    for d = 1:D
        tmp = zeros(H, W);
        ind = sub2ind([H W], y_(:), x_(:));
        tmp(ind) = im(:, :, d);
        tmp = reshape(tmp, [H W]);
        out(:, :, d) = tmp;
    end
    out = out / max(out(:));
    varargout{1} = out;
    if nargout == 3
        varargout{2} = x_;
        varargout{3} = y_;
    end
else
    varargout{1} = x_;
    varargout{2} = y_;
end
