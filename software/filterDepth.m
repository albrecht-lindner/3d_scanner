function out = filterDepth(in, S, th)

[H, W] = size(in);
out = zeros(H, W);
th = th*(S+1)^2;

for i = 1:H
    top = max(1, i-S);
    bot = min(H, i+S);
    for j = 1:W
        left = max(1, j-S);
        right = min(W, j+S);
        
        center = in(i, j);
        patch = in(top:bot, left:right);
        diff = abs(patch - center);
        count = sum(diff(:) < 10);
        if count > th
            out(i, j) = center;
        end
    end
end
