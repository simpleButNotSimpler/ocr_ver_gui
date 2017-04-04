function centerpoints = getcenterpoints(im1, refpoints)
%get the centroids
im = imcomplement(im1);
S  = regionprops(im,'centroid');
% S = bwconncomp(im, 8);
centroids = cat(1, S.Centroid);

%generate the computed centerpoints
row = size(refpoints, 1);
centerpoints = refpoints;
for t=1:row
    centerpoints(t, :) = closestpoints(centerpoints(t, :), centroids);
end

function  points = closestpoints(center, mat)
    [row, ~] = size(mat);
    center = mat - repmat(center, row, 1);
    
    center = sum(center.^2, 2);
    [~, idx] = min(center);
     points = mat(idx, :);
