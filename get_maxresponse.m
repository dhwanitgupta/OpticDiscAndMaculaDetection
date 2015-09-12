function [ mymax ] = get_maxresponse(temp , r)
% This function gives the correlation of the query box with the template

mymax = -1;
% circular template
d = draw_circle(2*r,r);
d(:,r-3:r+3) = 0;
d = uint8(d);
% checking for the max correlation 
for q = -30:15:30
    dr = imrotate(d,q,'crop');
    res = corr2(dr(:,:),temp) * 10000; 
    if res > mymax
        mymax = res;
    end
end
end

