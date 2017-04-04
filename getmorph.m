function im = getmorph(image, refpoints)
    im = image;
    se = strel('square', 3);
    for t=1:8
        xmin = refpoints(t,1) - 50;
        xmax = xmin + 100;
        ymin = refpoints(t,2) - 50;
        ymax = ymin + 100;
        proim = im(ymin:ymax, xmin:xmax);

        imout = imdilate(imdilate(proim, se), se);
        imout = imerode(imerode(imout, se), se);
        im(ymin:ymax, xmin:xmax) = imout;
    end
end