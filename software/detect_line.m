function idx = detect_line(im, channel)

if ~exist('channel', 'var')
    channel = 2;
end

W = size(im, 2);
W2 = floor(W/2);

K = 7;
f = [-1*ones(1,K) ones(1,K) -1*ones(1,K)];
f = f - mean(f);

signal = im(:, :, channel);
c = conv2(signal, f, 'same');
c(:, W2:end) = 0;
c(:, 1:2*K) = 0;
[~, idx] = max(c, [], 2);

% figure(111)
% hold off
% imagesc(im)
% hold on
% plot(idx, 1:size(im, 1), 'x')
% hold off
