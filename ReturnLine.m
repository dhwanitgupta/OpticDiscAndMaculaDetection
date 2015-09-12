function [xi,imgVess] = ReturnLine(image);

%Given a vessel map it detect the horizontal line which seperates the
% vessel map in equal parts 

[imgVess,temp] = vesdetect_v1(image);
[x,y] = size(imgVess);

minn = 100000000.000000000;

Xaxis = [];
Yaxis = [];

% brute force approach to check for the best horizontal line which
% seperates the vessel map in two equal parts

for i = x/8:x-x/8
    ind = find(imgVess(ceil(i),:) == 1);
    [on,temp] = size(ind);
    Xaxis(ceil(i)) = ceil(i);
    Yaxis(ceil(i)) = temp;
    ind = find(imgVess(1:i,:) == 1);
    inz = find(imgVess(1:i,:) == 0);
    [c1,tempx] = size(ind);
    [z1,tempz] = size(inz);
    dc1 = c1/(z1+c1);
    ind = find(imgVess(i:x,:) == 1);
    inz = find(imgVess(1:i,:) == 0);
    [c2,tempc] = size(ind);
    [z1,tempz] = size(inz);
    dc2 = c2/(z1+c2);
    diffones = abs(c2-c1);
    diffden = abs(dc2-dc1);
    differ = diffden;
    if minn > differ
        minn = differ;
        xi = i;
    end
end
imgVess(xi-10:xi+10,:) = 1;
%figure,imshow(imgVess);
end