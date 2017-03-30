function mat = rotatemat(points, angle)
    rm = [cos(angle), -sin(angle); sin(angle), cos(angle)];
    points = points';
    mat = points;
    
    row = size(mat, 1);
    for t=1:row
        mat(:, t) = rm * points(:, t); 
    end
    
    mat = mat';
end