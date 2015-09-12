function m = mymatch(flag,theta);
% Generating the match filter

kernel = zeros(15,15);
%kerne(4:12,1) = 5;
kernel(4:12,2) = 4;
kernel(4:12,3) = 3;
kernel(4:12,4) = 2;
kernel(4:12,5) = 1;
kernel(4:12,6) = -2;
kernel(4:12,7) = -5;
kernel(4:12,8) = -6;
kernel(4:12,9) = -5;
kernel(4:12,10) = -2;
kernel(4:12,11) = 1;
kernel(4:12,12) = 2;
kernel(4:12,13) = 3;
kernel(4:12,14) = 4;
%kernel(4:12,15) = 5;
Q = 15;
m = zeros(15,15);
while Q < 180 
    if Q == 90
        Q = Q + 15;
    end
    rot = imrotate(kernel,Q);
    [x,y] = size(rot);
    if x > 15
        m = m + rot(4:18,4:18);
    else
        m = m + rot;
    end
    
    Q = Q + 15;
end
%con = conv2(img,m/12);
%h = fspecial('median',5);
%con = imfilter(uint8(con),h);
%con = medfilt2(uint8(con));
%figure,subplot(1,2,1),imshow(img);
%subplot(1,2,2),imshow(uint8(con));
m = m/12;
end